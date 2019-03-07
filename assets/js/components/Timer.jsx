import React from 'react';

const padTime = value => {
  if (value < 10) {
    return `0${value}`;
  } else {
    return value;
  }
};

export default class Timer extends React.Component {
  state = {
    timediff: 0,
    intervalHandle: null,
    days: 0,
    hours: 0,
    minutes: 0,
    seconds: 0
  };

  componentDidMount = () => {
    const timediff = this.timeToWoff();
    const { days, hours, minutes, seconds } = this.getTime(timediff);
    const intervalHandle = setInterval(this.tick, 1000);

    this.setState({
      timediff,
      intervalHandle,
      days,
      hours,
      minutes,
      seconds
    });
  };

  tick = () => {
    const { days, hours, minutes, seconds } = this.getTime(this.state.timediff - 1);

    if (hours === 0 && minutes === 0 && seconds === 0) {
      clearInterval(this.state.intervalHandle);
    }

    this.setState({
      timediff: this.state.timediff - 1,
      days,
      hours,
      minutes,
      seconds
    });
  };

  getTime = timediff => {
    const days = Math.floor(timediff / 86400);
    const hours = Math.floor((timediff - days * 86400) / 3600);
    let remaining = timediff - hours * 3600;
    const minutes = Math.floor(remaining / 60) % 60;
    remaining -= minutes * 60;
    const seconds = remaining % 60;

    return {
      days,
      hours,
      minutes,
      seconds
    };
  };

  timeToWoff = () => {
    const date = new Date();
    date.setDate(date.getDate() + ((5 + 7 - date.getDay()) % 7));
    date.setHours(12);
    date.setMinutes(0);
    date.setSeconds(0);
    return Math.abs(date - Date.now()) / 1000;
  };

  render() {
    return (
      <span>
        {this.state.days > 0 ? `${this.state.days} days ` : ''}
        {padTime(this.state.hours)}:{padTime(this.state.minutes)}:{padTime(this.state.seconds)}
      </span>
    );
  }
}
