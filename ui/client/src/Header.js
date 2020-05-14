import React, { Component } from 'react';

// Libraries ----------
import Navbar from 'react-bootstrap/Navbar';
import NavDropdown from 'react-bootstrap/NavDropdown'
import Nav from 'react-bootstrap/Nav';

// Blockchain ----------
import getWeb3 from "./getWeb3";

export default class Header extends Component {
    
    constructor(props) {
        super(props);

        this.state = {
            userAccount: "",
            userBalance: null,
            networkId: null,
            chainId: null,
            protocolVersion: null,
            nodeInfos: null,
            latestBlock: null,
            gasPrice: null
        }
    }

    // show the address like in metamask
    showPartialAddress(_address) {
        let length = _address.length;
        let start = _address.slice(0, 6);
        let end = _address.slice(length - 4, length);
        return start + "..." + end;
    }

    componentDidMount = async () => {
        try {
            const web3 = await getWeb3();
            const accounts = await web3.eth.getAccounts();
            const balance = await web3.eth.getBalance(accounts[0]);
            const networkId = await web3.eth.net.getId();
            const chainId = await web3.eth.getChainId();
            const protocolVersion = await web3.eth.getProtocolVersion()
            const nodeInfos = await web3.eth.getNodeInfo();

            /** @todo the following items should be updated regularly */
            const latestBlock = await web3.eth.getBlockNumber()
            const gasPrice = await web3.eth.getGasPrice();

            this.setState({ 
                userAccount: accounts[0],
                userBalance: web3.utils.fromWei(balance),
                networkId: networkId,
                chainId: chainId,
                protocolVersion: protocolVersion,
                nodeInfos: nodeInfos,
                latestBlock: latestBlock,
                gasPrice: web3.utils.fromWei(gasPrice, 'GWei')
            })
        } catch(err) {
            // Catch any errors for any of the above operations.
            alert(
                `Failed to load web3, accounts, or network infos. Check console for details.`,
            );
            console.error(err);
        }
    }

    render() {
        return (
            <Navbar bg="light" expand="lg">
                <Navbar.Brand href="#home">Any.Sender</Navbar.Brand>
                <NavDropdown title="Network Infos" id="network-nav-dropdown">
                    <NavDropdown.Item>network id: {this.state.networkId}</NavDropdown.Item>
                    <NavDropdown.Item>chain id: {this.state.chainId}</NavDropdown.Item>
                    <NavDropdown.Item>protocol version: {this.state.protocolVersion}</NavDropdown.Item>
                    <NavDropdown.Divider />
                    <NavDropdown.Item>latest block: {this.state.latestBlock}</NavDropdown.Item>
                    <NavDropdown.Item>gas price (GWei): {this.state.gasPrice}</NavDropdown.Item>
                </NavDropdown>
                <Nav.Link>Node Infos: {this.state.nodeInfos}</Nav.Link>
                <Navbar.Collapse className="justify-content-end">
                    <Navbar.Text>
                        User: <a>{this.showPartialAddress(this.state.userAccount)}</a>
                    </Navbar.Text>
                    <Navbar.Text className="ml-3">
                        Balance: ♦ <a >{this.state.userBalance}</a>
                    </Navbar.Text>
                </Navbar.Collapse>
            </Navbar>
        );
    }
}