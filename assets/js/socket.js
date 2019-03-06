import { Socket } from 'phoenix';

let socket = new Socket('/socket', { params: { token: window.userToken } });
socket.connect();

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel('timer:update', {});
channel
  .join()
  .receive('ok', resp => {
    console.log('Joined successfully', resp);
  })
  .receive('error', resp => {
    console.log('Unable to join', resp);
  });

channel.on('new_time', payload => {
  document.getElementById('elixir-timer').innerText = payload.response;
});

export default socket;
