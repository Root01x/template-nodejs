import mosca from 'mosca'
import { config } from './config.js';
export const broker = new mosca.Server({
 port:config.port
 
})
broker.authenticate = function(client, username, password, callback) {
    // Implementa tu lógica de autenticación aquí
    const authorized = (username === 'cod-h-pb-t-0' && password.toString() === 'cod-h-pb-t-0');
    //client.id="dave00012"
    //console.log(client.user)
    callback(null, authorized);
    
  };
  
broker.on('clientConnected', function(client) {
    console.log('Cliente conectado:', client.id);
  });

broker.on('ready', () => {  
    console.log('Broker iniciado')   
})

// broker.on('published', (packet)=>{
//     console.log(packet.payload.toString())
// })
// broker.on('ready', () => {
//     console.log('Broker is ready')
// })
// broker.on('clienteconnected', (client) => {
//     console.log(`Client connected : ${client.id}`);
// })
// broker.on('published', (packet)=>{
//     console.log(packet.payload.toString())
// })

