import React, { Component } from 'react';

// Libraries ----------
import Jumbotron from 'react-bootstrap/Jumbotron';
import Button from 'react-bootstrap/Button'

import Background from './any-sender-background.jpg';

export default class Body extends Component {

    constructor(props) {
        super(props);
        this.state = {
            website: "https://www.anydot.dev/",
            github: "https://github.com/PISAresearch/docs.any.sender",
            medium: "https://medium.com/anydot/any-sender-transactions-made-simple-34b36ba7519b"
        }
    }

    render() {
        return (
            <div>
                <Jumbotron style={{
                    backgroundImage: `url(${Background})`,
                    backgroundPosition: 'center',
                    backgroundRepeat: 'no-repeat',
                    color: 'white'
                }}>
                    <h1>Welcome to Any.Sender</h1>
                    <p>a simple and efficient way of sending transactions to Ethereum</p>
                    <p>
                        <Button className="mr-3" target="_blank" variant="primary" href={this.state.website}>Website</Button>
                        <Button className="mr-3" target="_blank" variant="secondary" href={this.state.github}>Github</Button>
                        <Button className="mr-3" target="_blank" variant="success" href={this.state.medium}>Medium</Button>
                    </p>
                </Jumbotron>
            </div>
        )
    }
}