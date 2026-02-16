// SPDX-License-Identifier: AGPL-3.0
// The MegaPoker
//
// Copyright (C) 2020 Maker Ecosystem Growth Holdings, INC.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

pragma solidity ^0.6.12;

contract PokingAddresses {
    // OSMs
    address constant btc            = 0xf185d0682d50819263941e5f4EacC763CC5C6C42;
    address constant eth            = 0x81FE72B5A8d1A857d176C3E7d5Bd2679A9B85763;
    address constant wsteth         = 0xFe7a2aC0B945f12089aEEB6eCebf4F384D9f043F;
    address constant sky            = 0x511485bBd96e7e3a056a8D1b84C5071071C52D6F;

    // Spotter
    address constant spotter        = 0x65C79fcB50Ca1594B025960e539eD7A9a6D434A3;
}

contract MegaPoker is PokingAddresses {
    function poke() external {
        bool ok;

        // poke() = 0x18178358
        (ok,) = btc.call(abi.encodeWithSelector(0x18178358));
        (ok,) = eth.call(abi.encodeWithSelector(0x18178358));
        (ok,) = wsteth.call(abi.encodeWithSelector(0x18178358));
        (ok,) = sky.call(abi.encodeWithSelector(0x18178358));

        // poke(bytes32) = 0x1504460f
        (ok,) = spotter.call(abi.encodeWithSelector(0x1504460f, bytes32("ETH-A")));
        (ok,) = spotter.call(abi.encodeWithSelector(0x1504460f, bytes32("ETH-B")));
        (ok,) = spotter.call(abi.encodeWithSelector(0x1504460f, bytes32("ETH-C")));
        (ok,) = spotter.call(abi.encodeWithSelector(0x1504460f, bytes32("WBTC-A")));
        (ok,) = spotter.call(abi.encodeWithSelector(0x1504460f, bytes32("WBTC-B")));
        (ok,) = spotter.call(abi.encodeWithSelector(0x1504460f, bytes32("WBTC-C")));
        (ok,) = spotter.call(abi.encodeWithSelector(0x1504460f, bytes32("WSTETH-A")));
        (ok,) = spotter.call(abi.encodeWithSelector(0x1504460f, bytes32("WSTETH-B")));
        (ok,) = spotter.call(abi.encodeWithSelector(0x1504460f, bytes32("LSEV2-SKY-A")));
    }
}
