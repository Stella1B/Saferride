const express = require('express')
const app = express()
const http = require('http')
const WebSocket = require('ws')

const server = http.createServer(app)
const wss = new WebSocket.Server({ server })

app.use((req, res, next) => {
    res.set('Content-Security-Policy', "default-src 'self' https://one-client.onrender.com; script-src 'self' 'unsafe-inline';")
    res.set('Cross-Origin-Opener-Policy', "cross-origin")
    res.set('Access-Control-Allow-Origin', "*")
    res.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
    res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization')
    next()
})

app.options('*', (req, res) => {
    res.set('Access-Control-Allow-Origin', "*");
    res.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    res.sendStatus(200);
});


let pendingClient = null
let activeRider = null
let activeClient = null

app.get('/', (req, res) => {
    res.send('Hello client')
})

wss.on('connection', (ws) => {
    console.log('New client connected')

    ws.on('message', (message) => {
        console.log('Received:', message)
        try {
            const data = JSON.parse(message)
        } catch (error) {
            console.error('Error parsing message:', error)
        }

        if (data.type === 'client') {
            if (data.action === 'requestRider') {
                pendingClient = { ws, coordinates: data.coordinates }
                broadcastToRiders({ message: 'Client pending', coordinates: data.coordinates })
            } else if (data.action === 'distress') {
                broadcastToRiders({ message: 'Distress call', coordinates: data.coordinates })
            }
        } else if (data.type === 'rider') {
            if (data.action === 'agree' && pendingClient) {
                activeRider = ws
                pendingClient.ws.send(JSON.stringify({ message: 'Rider is on the way' }))
                broadcastToRiders({ message: 'No more pending for this client' }, ws)
                activeClient = pendingClient.ws
                pendingClient = null
            } else if (data.action === 'startTrip' && activeRider === ws) {
                activeClient.send(JSON.stringify({ message: 'Trip started' }))
            } else if (data.action === 'endTrip' && activeRider === ws) {
                activeClient.send(JSON.stringify({ message: 'Trip ended' }))
                activeClient = null
                activeRider = null
            }
        }
    })

    ws.on('close', () => {
        console.log('Client disconnected')
        if (ws === activeRider) {
            activeRider = null
        }
    })
})

function broadcastToRiders(message, excludeWs = null) {
    wss.clients.forEach((client) => {
        if (client !== excludeWs && client.readyState === WebSocket.OPEN) {
            client.send(JSON.stringify(message))
        }
    })
}

server.listen(3000, () => {
    console.log('Socket Server is running on port 3000')
})
