"use strict";
const IS_DEV = process.env.IS_DEV || process.env.NODE_ENV === "development";
const log = require("loglevel");

module.exports = {
    gcp: {
        projectId: 'placeholderProjectID',
        topic: 'placeholderTopic',
        subscription: 'placeholderSubscription',
        processId: 'placeholderProcessId',
        bucket: 'placeholderBucket',
        keyFilename: './secrets/somekey.json',
    },
    redis: {
        host: IS_DEV ? 'localhost' : 'placeholderRedis',
        password: 'placeholderPassword'
    },
    loggingLevel: log.levels.INFO,
    /* Times, in seconds, for data retention */
    // Data period to be kept for the API
    windowPeriod: 'placeholderWindow',
    // How much of backlog data should be kept in addition to windowPeriod. Means Reddis will
    // store at least windowPeriod + backlogPeriod in total
    backlogPeriod: 'placeholderBacklog',
    // How often should the storage process run
    writeInterval: 'placeholderWrite',
    dataProcessInterval: 'placeholderProcess',
    projectName: 'placeholderRepoName',
    deploySSHPath: 'ubuntu@placeholderSsh.com',
    domain: 'placeholderDomain.vivacitylabs.com'
};