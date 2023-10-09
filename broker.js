const mosca = require('mosca')
//const port2 = process.env.MQTTPORT ?? 1883;
const config = require('./config')
const broker = new mosca.Server({
 port:config.port,
 host:config.host 
})
broker.authenticate = function(client, username, password, callback) {
    // Implementa tu lógica de autenticación aquí
    const authorized = (username === 'user01' && password.toString() === '12345678');
    client.id="dave00012"
    console.log(client.user)
    callback(null, authorized);
    
  };
  
broker.on('clientConnected', function(client) {
    console.log('Cliente conectado:', client.id);
  });

broker.on('ready', () => {  
    console.log('Broker iniciado')
    setInterval(()=>{        
        
        console.log('...')
        
    },10000) 
})

broker.on('published', (packet)=>{
    console.log(packet.payload.toString())
})
// broker.on('ready', () => {
//     console.log('Broker is ready')
// })
// broker.on('clienteconnected', (client) => {
//     console.log(`Client connected : ${client.id}`);
// })
// broker.on('published', (packet)=>{
//     console.log(packet.payload.toString())
// })
module.exports
