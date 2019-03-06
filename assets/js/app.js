import 'phoenix_html';
import React from 'react';
import ReactDOM from 'react-dom';
import './socket';

// React Components
import Timer from './components/Timer';
ReactDOM.render(<Timer />, document.getElementById('react-timer'));

// Elm Program
import { Elm } from '../elm/src/Timer.elm';
const elmDiv = document.getElementById('elm-counter');

Elm.Timer.init({ node: elmDiv });
