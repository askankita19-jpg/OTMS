package com.otms

class PipelineConfig implements Serializable {

    static Map applications() {

        return [
            frontend: [
                appName: 'otms-frontend',
                appType: 'node'
            ],

            employee: [
                appName: 'otms-employee-api',
                appType: 'go'
            ],

            attendance: [
                appName: 'otms-attendance-api',
                appType: 'python'
            ],

            salary: [
                appName: 'otms-salary-api',
                appType: 'java'
            ],

            notification: [
                appName: 'otms-notification',
                appType: 'python'
            ]
        ]
    }
}
