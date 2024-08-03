const express = require('express')
const app = express()
const http = require('http')
require('dotenv').config()
const WebSocket = require('ws')
const { v4: uuidv4 } = require('uuid')
const twilio = require("twilio")

const server = http.createServer(app)
const wss = new WebSocket.Server({ server })

const accountSidTwilio = process.env.TWILIO_ACCOUNT_SID
const authTokenTwilio = process.env.TWILIO_AUTH_TOKEN
const clientTwilio = twilio(accountSidTwilio, authTokenTwilio)

const ACCESS_TOKEN = process.env.ACCESS_TOKEN
const PHONE_NUMBER_ID = process.env.PHONE_NUMBER_ID
const WHATSAPP_API_URL = `https://graph.facebook.com/v20.0/${PHONE_NUMBER_ID}/messages`

app.use(express.json())

app.use((req, res, next) => {
    res.set('Content-Security-Policy', "default-src 'self' https://one-client.onrender.com; script-src 'self' 'unsafe-inline';")
    res.set('Cross-Origin-Opener-Policy', "cross-origin")
    res.set('Access-Control-Allow-Origin', "*")
    res.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
    res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization')
    next()
})

app.options('*', (req, res) => {
    res.set('Access-Control-Allow-Origin', "*")
    res.set('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
    res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization')
    res.sendStatus(200)
})

let pendingClient = null
let activeRider = null
let activeClient = null

app.get('/', (req, res) => {
    res.send('Hello client')
})

const distressed = {}

app.get('/findDistressed', (req, res) => {
    console.log('Found seeker of the lost')
    res.send(distressed.coordinates || {})
    setTimeout(() => {
        distressed['coordinates'] = {}
    }, 2000)
})

app.post('/distress', (req, res) => {
    console.log('distress call received:', req.body)
    distressed['coordinates'] = req.body.coordinates
    res.send('distress message has been broadcast')
})

wss.on('connection', (ws) => {
    ws.id = uuidv4()
    console.log('New client connected', ws.id)

    console.log('pending:', pendingClient ? pendingClient.ws.id : 'none')
    console.log('activeRider:', activeRider ? activeRider.ws.id : 'none')
    console.log('activeClient:', activeClient ? activeClient.ws.id : 'none')

    ws.on('message', (message) => {
        try {
            const data = JSON.parse(message)
            console.log('Received:', data)
            if (data.type === 'client') {
                if (data.action === 'requestRider') {
                    pendingClient = { ws, coordinates: data.coordinates }
                    console.log('got a rider request:', pendingClient.ws.id)
                    broadcastToRiders({ message: 'Client pending', coordinates: data.coordinates }, ws)
                } else if (data.action === 'distress') {
                    console.log('got a distress call from', ws.id)
                    broadcastToRiders({ message: 'Distress call', coordinates: data.coordinates }, ws)
                }
            } else if (data.type === 'rider') {
                if (data.action === 'agree' && pendingClient) {
                    console.log('got an agree:', data)
                    activeRider = ws
                    pendingClient.ws.send(JSON.stringify({ message: 'Rider is on the way' }))
                    console.log('sending message to client:', pendingClient.ws.id)
                    broadcastToRiders({ message: 'No more pending for this client' }, ws)
                    activeClient = pendingClient.ws
                    pendingClient = null
                } else if (data.action === 'startTrip' && activeRider === ws) {
                    activeClient.send(JSON.stringify({ message: 'Trip started' }))
                } else if (data.action === 'endTrip' && activeRider === ws) {
                    activeClient.send(JSON.stringify({ message: 'Trip ended' }))
                    console.log('sent end trip message to', activeClient.ws.id)
                    activeClient = null
                    activeRider = null
                }
            } else {
                console.log('unknown message:', data)
                ws.send(JSON.stringify({ message: 'Unknown message' }))
            }
        } catch (error) {
            console.error('Error parsing message:', error)
        }
    })

    ws.on('close', () => {
        console.log('Client disconnected', ws.id)
        if (ws === activeRider) {
            activeRider = null
        }
    })
})

function broadcastToRiders(message, excludeWs = null) {
    console.log('Broadcasting to riders:')
    wss.clients.forEach((client) => {
        if (client !== excludeWs && client.readyState === WebSocket.OPEN) {
            client.send(JSON.stringify(message))
            console.log('Message sent to rider:', client.id)
        }
    })
}

app.post('/sendMessage', async (req, res) => {
    // const {familyName, familyPhone, clientName, riderName, setOffTime, destination} = req.body
    console.log('Whatsapp sending parameters;', req.body)

    // const payload = {
    //     messaging_product: 'whatsapp',
    //     to: familyPhone,
    //     type: 'template',
    //     template: {
    //       name: 'traveler',
    //       language: { code: 'en' },
    //       components: [
    //         {
    //           type: 'body',
    //   parameters: [
    //     { type: 'text', text: "John Katumba" },
    //     { type: 'text', text: "Janet Kowalski" },
    //     { type: 'text', text: "Dory Othieno" },
    //     { type: 'text', text: "1500Hrs" },
    //     { type: 'text', text: "Mukono Wantoni" }
    //   ]
    //   parameters: [
    //     { type: 'text', text: `${familyName}` },
    //     { type: 'text', text: `${clientName}` },
    //     { type: 'text', text: `${riderName}` },
    //     { type: 'text', text: `${setOffTime}` },
    //     { type: 'text', text: `${destination}` }
    //   ]
    //         }
    //       ]
    //     }
    //   };

    const payload = {
        messaging_product: "whatsapp",
        to: "+256783103587",
        type: "template",
        template: {
            name: "hello_world",
            language: {
                code: "en_US"
            }
        }
    }

    try {
        const response = await fetch(WHATSAPP_API_URL, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${ACCESS_TOKEN}`,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(payload)
        })

        const responseData = await response.json()
        console.log('response from sending whatsapp:', responseData.messages[0].message_status)
        res.status(response.status).json(responseData)
    } catch (error) {
        console.error('Error sending message:', error)
        res.status(500).json({ error: 'Failed to send message.' })
    }
})

app.post('/sendSms', async (req, res) => {

    const { familyName, familyPhone, clientName, riderName, setOffTime, destination } = req.body
    console.log('called sendSms:', familyName, clientName, riderName, destination)
    const sending = await clientTwilio.messages.create({
        body: `Hello, ${familyName}.
        ${clientName} is travelling with Saferride and would like to share with you their travel details:
        Name of rider: ${riderName}
        Set off time: ${setOffTime}
        Destination: ${destination}`,
        from: "+18156450924",
        to: "+256783103587",
    })
    // const sendResp = await sending.json()
    console.log('sending fate:', sending)
})

server.listen(3000, () => {
    console.log('Socket Server is running on port 3000')
})
