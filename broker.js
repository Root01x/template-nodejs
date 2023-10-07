const mosca = require('mosca')
const broker = new mosca.Server({
    port:1234
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
    console.log('Broker is ready')
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