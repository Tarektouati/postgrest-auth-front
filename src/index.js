import './assets/main.css';
import { Elm } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';
import HelloJs from 'hellojs';

const hello = HelloJs.init({
  google: process.env.ELM_APP_GOOGLE_CLIENTID,
  facebook: process.env.ELM_APP_FACEBOOK_CLIENTID
});

const helloOpts = {
  redirect_uri: process.env.ELM_APP_REDIRECT_URL,
  state: 'random-state',
  scope: 'email'
};
var app = Elm.Main.init({
  node: document.getElementById('root'),
  flags: {
    api: process.env.ELM_APP_API,
    state: 'random-state'
  }
});
const login = provider => {
  hello
    .login(provider, helloOpts)
    .then(async () => {
      const res = await hello(provider).getAuthResponse();
      app.ports.token.send({ token: res.access_token, provider: provider });
    })
    .catch(console.error);
};

app.ports.login.subscribe(provider => login(provider));

registerServiceWorker();
