def call(Map config = [:]) {

    def type = config.type
    def action = config.action ?: 'build'

    if (type == 'go') {

        if (action == 'build') {
            sh 'go build ./...'
        }

        if (action == 'test') {
            sh 'go test ./...'
        }

        if (action == 'package') {
            sh '''
                mkdir -p artifacts
                go build -o artifacts/application .
            '''
        }

    } else if (type == 'python') {

        if (action == 'build') {
            sh '''
                python3 -m venv .venv
                .venv/bin/pip install -r requirements.txt
            '''
        }

        if (action == 'test') {
            sh '.venv/bin/pytest'
        }

        if (action == 'package') {
            sh '''
                mkdir -p artifacts
                tar -czf artifacts/application.tar.gz .
            '''
        }

    } else if (type == 'java') {

        if (action == 'build') {
            sh './mvnw clean package -DskipTests'
        }

        if (action == 'test') {
            sh './mvnw test'
        }

        if (action == 'package') {
            sh '''
                mkdir -p artifacts
                cp target/*.jar artifacts/application.jar
            '''
        }

    } else if (type == 'node') {

        if (action == 'build') {
            sh '''
                npm ci
                npm run build
            '''
        }

        if (action == 'test') {
            sh 'npm test -- --watchAll=false'
        }

        if (action == 'package') {
            sh '''
                mkdir -p artifacts
                tar -czf artifacts/application.tar.gz build
            '''
        }

    } else {
        error "Unsupported application type: ${type}"
    }
}
