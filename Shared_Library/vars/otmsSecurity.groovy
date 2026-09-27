def secretScan() {

    sh '''
        gitleaks detect \
          --source . \
          --no-banner \
          --redact
    '''
}

def trivyScan() {

    sh '''
        trivy fs \
          --exit-code 1 \
          --severity HIGH,CRITICAL \
          .
    '''
}
