def call(Map config = [:]) {

    def status = config.status
    def application = config.application

    echo "Application: ${application}"
    echo "Pipeline Status: ${status}"
    echo "Build: ${env.BUILD_NUMBER}"
    echo "Job: ${env.JOB_NAME}"
}
