// SPDX-License-Identifier: AGPL-3.0
// The OmegaPoker
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

pragma solidity ^0.6.11;

pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "./OmegaPoker.sol";

interface SpellLike {
    function eta() external view returns (uint256);
    function done() external view returns (bool);
    function schedule() external;
    function cast() external;
}

interface ChainLogLike {
    function getAddress(bytes32) external view returns (address);
}


interface VatLike {
    function ilks(bytes32) external view returns (uint256);
}

interface PauseLike {
    function delay() external view returns (uint256);
}

interface ChiefLike {
    function hat() external view returns (address);
    function lift(address) external;
    function lock(uint256) external;
    function vote(address[] calldata) external;
}

interface TokenLike {
    function approve(address, uint256) external;
}

interface Hevm {
    function warp(uint256) external;
    function store(address,bytes32,bytes32) external;
}

interface OsmLike {
    function pass() external view returns (bool);
}

interface RegistryLike {
    function pip(bytes32) external returns (address);
    function file(bytes32,bytes32,address) external;
    function removeAuth(bytes32) external;
}


contract OmegaPokerTest is Test {
    SpellLike    constant spell     = SpellLike(address(0));
    SpellLike    constant prevSpell = SpellLike(address(0));

    ChainLogLike constant changelog = ChainLogLike(0xdA0Ab1e0017DEbCd72Be8599041a2aa3bA7e740F);

    PauseLike pause;
    ChiefLike chief;
    TokenLike govToken;

    Hevm hevm;

    OmegaPoker omegaPoker;

    bytes20 constant CHEAT_CODE = bytes20(uint160(uint256(keccak256('hevm cheat code'))));

    function setUp() public {
        hevm = Hevm(address(CHEAT_CODE));
        omegaPoker = new OmegaPoker();
        omegaPoker.refresh();
        pause = PauseLike(changelog.getAddress("MCD_PAUSE"));
        chief = ChiefLike(changelog.getAddress("MCD_ADM"));
        govToken = TokenLike(changelog.getAddress("MCD_GOV"));
        hevm.warp(now + 3600);
    }

    function vote(SpellLike spell_) private {
        if (chief.hat() != address(spell_)) {
            hevm.store(
                address(govToken),
                keccak256(abi.encode(address(this), uint256(1))),
                bytes32(uint256(999999999999 ether))
            );
            govToken.approve(address(chief), uint256(-1));
            chief.lock(999999999999 ether);

            assertTrue(!spell_.done());

            address[] memory yays = new address[](1);
            yays[0] = address(spell_);

            chief.vote(yays);
            chief.lift(address(spell_));
        }
        assertEq(chief.hat(), address(spell_));
    }

    function schedule(SpellLike spell_) public {
        if (spell_.eta() == 0) {
            spell_.schedule();
        }
        assertTrue(spell.eta() > 0);
    }

    function waitAndCast(SpellLike spell_) public {
        uint256 castTime = now + pause.delay();

        uint256 day = (castTime / 1 days + 3) % 7;
        if(day >= 5) {
            castTime += 7 days - day * 86400;
        }

        uint256 hour = castTime / 1 hours % 24;
        if (hour >= 21) {
            castTime += 24 hours - hour * 3600 + 14 hours;
        } else if (hour < 14) {
            castTime += 14 hours - hour * 3600;
        }

        hevm.warp(castTime);
        spell_.cast();
    }

    function try_poke() internal returns (bool ok) {
        (ok,) = address(omegaPoker).call(abi.encodeWithSignature("poke()"));
    }

    function test_poke() public {
        if (address(prevSpell) != address(0) && !prevSpell.done()) {
            vote(prevSpell);
            schedule(prevSpell);
            waitAndCast(prevSpell);
        }
        if (address(spell) != address(0) && !spell.done()) {
            vote(spell);
            schedule(spell);
            assertTrue(!try_poke());
            waitAndCast(spell);
        }

        assertTrue(try_poke());
    }

    function testRefresh() public {
        // grant ourselves authority on the ilk registry
        address registry = address(omegaPoker.registry());
        hevm.store(registry, keccak256(abi.encode(address(this), uint(0))), bytes32(uint(1)));

        uint256 ilkcount = omegaPoker.ilkCount();
        uint256 osmcount = omegaPoker.osmCount();
        assertTrue(ilkcount > 1);
        assertTrue(osmcount > 1);

        RegistryLike(registry).removeAuth("BAT-A"); // Remove Ilk + OSM

        omegaPoker.refresh();

        assertEq(omegaPoker.ilkCount(), --ilkcount);  // Remove BAT-A ilk from spot call
        assertEq(omegaPoker.osmCount(), --osmcount);  // Remove bat osm

        RegistryLike(registry).removeAuth("ETH-A"); // Remove Ilk but leave OSM

        omegaPoker.refresh();

        assertEq(omegaPoker.ilkCount(), --ilkcount);  // Remove ETH-A ilk from spotter call
        assertEq(omegaPoker.osmCount(), osmcount);    // Do not remove osm because it's used by ETH-B, etc.

        RegistryLike(registry).removeAuth("USDC-A"); // Remove ilk without OSM

        omegaPoker.refresh();

        assertEq(omegaPoker.ilkCount(), ilkcount);    // Ilk should not have been poked because no OSM
        assertEq(omegaPoker.osmCount(), osmcount);    // No osm to remove
    }

    function testRefreshZeroPip() public {
        // grant ourselves authority on the ilk registry
        address registry = address(omegaPoker.registry());
        hevm.store(registry, keccak256(abi.encode(address(this), uint(0))), bytes32(uint(1)));

        // Ensure we can refresh and poke
        omegaPoker.refresh();

        RegistryLike(registry).file("ETH-A", "pip", address(0)); // Remove PIP
        assertEq(RegistryLike(registry).pip("ETH-A"), address(0));

        // Ensure we can still refresh and poke
        omegaPoker.refresh();
        
        for (uint i = 0; i < omegaPoker.osmCount(); i++) {
            address osm = omegaPoker.osms(i);
            assertTrue(osm != address(0));
        }
    }

    function testPoke() public {
        for (uint i = 0; i < omegaPoker.osmCount(); i++) {
            OsmLike osm = OsmLike(omegaPoker.osms(i));
            assertTrue(osm.pass());
        }

        omegaPoker.poke();

        for (uint i = 0; i < omegaPoker.osmCount(); i++) {
            OsmLike osm = OsmLike(omegaPoker.osms(i));
            assertTrue(!osm.pass());
        }
    }

    function testRefreshCost() public {
        omegaPoker.refresh();
    }

    function testPokeCost() public {
        omegaPoker.poke();
    }
}
