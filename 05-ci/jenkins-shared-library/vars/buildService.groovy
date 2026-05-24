#!/usr/bin/env groovy

/**
 * Build a single microservice based on its language/technology.
 *
 * Usage:
 *   buildService('ui')         // Java Maven
 *   buildService('catalog')    // Go
 *   buildService('checkout')   // Node.js / TypeScript / NestJS
 *
 * @param service  Service name (ui, cart, orders, catalog, checkout)
 */
def call(String service) {
    echo "Building service: ${service}"

    switch (service) {
        case 'ui':
        case 'cart':
        case 'orders':
            sh './mvnw --no-transfer-progress -DskipTests package'
            break

        case 'catalog':
            sh 'go build -o dist/main main.go'
            break

        case 'checkout':
            sh 'yarn install --frozen-lockfile'
            sh 'yarn build'
            break

        default:
            error "Unknown service type: ${service}"
    }
}
