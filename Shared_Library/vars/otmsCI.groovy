def call(Map config = [:]) {

    pipeline {

        agent any

        environment {
            APP_NAME = config.appName
            APP_TYPE = config.appType
            VERSION = "${BUILD_NUMBER}"
            ARTIFACT_DIR = "artifacts"
        }

        stages {

            stage('Checkout') {
                steps {
                    checkout scm
                }
            }

            stage('Secret Scan') {
                steps {
                    otmsSecurity.secretScan()
                }
            }

            stage('Build') {
                steps {
                    otmsBuild(
                        type: env.APP_TYPE
                    )
                }
            }

            stage('Test') {
                steps {
                    otmsBuild(
                        type: env.APP_TYPE,
                        action: 'test'
                    )
                }
            }

            stage('Security Scan') {
                steps {
                    otmsSecurity.trivyScan()
                }
            }

            stage('Package') {
                steps {
                    otmsBuild(
                        type: env.APP_TYPE,
                        action: 'package'
                    )
                }
            }

            stage('Archive') {
                steps {
                    archiveArtifacts(
                        artifacts: 'artifacts/**',
                        fingerprint: true
                    )
                }
            }
        }

        post {

            success {
                otmsNotify(
                    status: 'SUCCESS',
                    application: env.APP_NAME
                )
            }

            failure {
                otmsNotify(
                    status: 'FAILURE',
                    application: env.APP_NAME
                )
            }
        }
    }
}
