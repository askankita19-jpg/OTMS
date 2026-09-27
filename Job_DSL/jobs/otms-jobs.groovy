def applications = [
    [
        name: 'otms-frontend',
        repository: 'OTMS-Frontend',
        branch: 'main'
    ],
    [
        name: 'otms-employee-api',
        repository: 'OTMS-Employee-API',
        branch: 'main'
    ],
    [
        name: 'otms-attendance-api',
        repository: 'OTMS-Attendance-API',
        branch: 'main'
    ],
    [
        name: 'otms-salary-api',
        repository: 'OTMS-Salary-API',
        branch: 'main'
    ],
    [
        name: 'otms-notification',
        repository: 'OTMS-Notification',
        branch: 'main'
    ]
]

applications.each { app ->

    pipelineJob(app.name) {

        description("OTMS CI pipeline for ${app.repository}")

        definition {
            cpsScm {
                scm {
                    git {
                        remote {
                            url("https://github.com/askankita19-jpg/${app.repository}.git")
                        }

                        branch(app.branch)
                    }
                }

                scriptPath('Jenkinsfile')
            }
        }

        logRotator {
            numToKeep(20)
            artifactNumToKeep(10)
        }

        properties {
            disableConcurrentBuilds()
        }
    }
}
