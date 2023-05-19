//
// Check input samplesheet and get read channels
//

include { SAMPLESHEET_CHECK } from '../../modules/local/samplesheet_check'

workflow INPUT_CHECK {
    take:
    samplesheet // file: /path/to/samplesheet.csv

    main:
    SAMPLESHEET_CHECK ( samplesheet )
        .csv
        .splitCsv ( header:true, sep:',' )
        .map { create_pairs_channel(it) }
        .set { pairs }

    emit:
    pairs                                     // channel: [ val(meta), [ pairs ] ]
    versions = SAMPLESHEET_CHECK.out.versions // channel: [ versions.yml ]
}

// Function to get list of [ meta, pairs ]
def create_pairs_channel(LinkedHashMap row) {
    // create meta map
    def meta = [:]
    meta.id         = row.sample

    // add path(s) of the pairs file(s) to the meta map
    def pairs_meta = []
    if (!file(row.pairs).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> Pairs file does not exist!\n${row.pairs_1}"
    }
    pairs_meta = [ meta, [ file(row.pairs) ] ]
    return pairs_meta
}
