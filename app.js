import express from 'express';
import logger from 'morgan'
import { Server } from 'socket.io';
import {createServer} from 'node:http'
import { broker } from './broker.js';

const app = express();
const port = process.env.PORT ?? 3000;
const server = createServer(app)
const io = new Server(server)
let sum = 0

app.use(logger('dev'))
app.use(express.static('public'))
//routing
app.get('*', (req, res) => {
    res.redirect('/');
})

io.on('connection', (socket)=>{
    console.log('Un usuario connectado')

    socket.on('disconnect', () =>{
        console.log('Un usuario se ha desconectado')
    })

    broker.on('published', (packet)=>{
        io.emit('chat message', packet.payload.toString())
        console.log(packet.payload.toString())
    })
    // const broadcast = () =>{
    //     sum =sum +1
    //     const values = {kw:1+sum, amp:2+sum}
    //     const plusValues = values
    //     io.emit('chat message', values)
    // }
    // setInterval(broadcast , 2000)
    
})


server.listen(port, () => {
    console.log(`App listening on port ${port}`);
    //require('./broker.js')
})

