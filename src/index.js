import './assets/main.css';
import { Elm } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';
import hello from '../lib/hello';

const socialLogin = hello.init({
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
  socialLogin
    .login(provider, helloOpts)
    .then(({ authResponse }) =>
      app.ports.token.send({ token: authResponse.access_token, provider: provider })
    );
};

app.ports.login.subscribe(login);

registerServiceWorker();
