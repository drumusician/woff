import React from 'react';

const initialState = {
  timediff: 0,
  intervalHandle: 0,
  days: 0,
  hours: 0,
  minutes: 0,
  seconds: 0
}

const padTime = (value) => {
  if (value < 10) {
    return `0${value}`;
  } else {
    return value;
  }
}

export default class Timer extends React.Component {
  constructor(props) {
    super(props)

    // Set the initial state of the component in a constructor.
    this.state = initialState
  }

  componentDidMount = () => {
    const timediff = this.timeToWoff();
    const {days, hours, minutes, seconds} = this.getTime(timediff);
    const intervalHandle = setInterval(this.tick, 1000);

    this.setState({
      timediff: timediff,
      intervalHandle: intervalHandle,
      days: days,
      hours: hours,
      minutes: minutes,
      seconds: seconds
    });

  }

  render() {
    return (
      <span>
        {(this.state.days > 0) ? `${this.state.days} days ` : ''}
        {padTime(this.state.hours)}:
        {padTime(this.state.minutes)}:
        {padTime(this.state.seconds)}
       </span>
    )
  }

  tick = () => {
    const { days, hours, minutes, seconds } = this.getTime(this.state.timediff - 1);

    if (hours === 0 && minutes === 0 && seconds === 0) {
      clearInterval(this.state.intervalHandle);
    }

    this.setState({
      timediff: this.state.timediff -1,
      days: days,
      hours: hours,
      minutes: minutes,
      seconds: seconds
    });
  }

  getTime = (timediff) =>  {
    const days = Math.floor(timediff / 86400)
    const hours = Math.floor((timediff - days * 86400) / 3600);
    timediff -= hours * 3600;
    const minutes = Math.floor(timediff / 60) % 60;
    timediff -= minutes * 60;
    const seconds = timediff % 60;

    return {
      days, hours, minutes, seconds
    }
  }

  timeToWoff = () => {
    const date = new Date();
    date.setDate(date.getDate() + (5 + 7 - date.getDay()) % 7);
    date.setHours(12);
    date.setMinutes(0);
    date.setSeconds(0);
    return Math.abs(date - Date.now()) / 1000;
  }
}

