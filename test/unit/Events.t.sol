// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.18;

import {Test} from "lib/forge-std/src/Test.sol";
import {Account} from "../../src/Account.sol";
import {ConsolidatedEvents} from "../utils/ConsolidatedEvents.sol";
import {Events} from "../../src/Events.sol";
import {Factory} from "../../src/Factory.sol";
import {IAccount} from "../../src/interfaces/IAccount.sol";
import {IEvents} from "../../src/interfaces/IEvents.sol";
import {Setup} from "../../script/Deploy.s.sol";
import "../utils/Constants.sol";

contract EventsTest is Test, ConsolidatedEvents {
    /*//////////////////////////////////////////////////////////////
                                 STATE
    //////////////////////////////////////////////////////////////*/

    // main contracts
    Factory private factory;
    Events private events;
    address private account;

    /*//////////////////////////////////////////////////////////////
                                 SETUP
    //////////////////////////////////////////////////////////////*/

    function setUp() public {
        vm.rollFork(BLOCK_NUMBER);

        // define Setup contract used for deployments
        Setup setup = new Setup();

        // deploy system contracts
        (factory, events,,) = setup.deploySystem({
            _deployer: address(0),
            _owner: address(this),
            _addressResolver: ADDRESS_RESOLVER,
            _gelato: GELATO,
            _ops: OPS
        });

        // deploy an Account contract
        account = factory.newAccount();
    }

    /*//////////////////////////////////////////////////////////////
                                 TESTS
    //////////////////////////////////////////////////////////////*/

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    function test_Constructor_FactorySet() public {
        assertEq(events.factory(), address(factory));
    }

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    function test_EmitDeposit_Event() public {
        vm.expectEmit(true, true, true, true);
        emit Deposit(USER, address(account), AMOUNT);
        vm.prank(account);
        events.emitDeposit({user: USER, amount: AMOUNT});
    }

    function test_EmitDeposit_OnlyAccounts() public {
        vm.expectRevert(abi.encodeWithSelector(IEvents.OnlyAccounts.selector));
        events.emitDeposit({user: USER, amount: AMOUNT});
    }

    function test_EmitWithdraw_Event() public {
        vm.expectEmit(true, true, true, true);
        emit Withdraw(USER, address(account), AMOUNT);
        vm.prank(account);
        events.emitWithdraw({user: USER, amount: AMOUNT});
    }

    function test_EmitWithdraw_OnlyAccounts() public {
        vm.expectRevert(abi.encodeWithSelector(IEvents.OnlyAccounts.selector));
        events.emitWithdraw({user: USER, amount: AMOUNT});
    }

    function test_EmitEthWithdraw_Event() public {
        vm.expectEmit(true, true, true, true);
        emit EthWithdraw(USER, address(account), AMOUNT);
        vm.prank(account);
        events.emitEthWithdraw({user: USER, amount: AMOUNT});
    }

    function test_EmitEthWithdraw_OnlyAccounts() public {
        vm.expectRevert(abi.encodeWithSelector(IEvents.OnlyAccounts.selector));
        events.emitEthWithdraw({user: USER, amount: AMOUNT});
    }

    function test_EmitConditionalOrderPlaced_Event() public {
        uint256 conditionalOrderId = 0;
        vm.expectEmit(true, true, true, true);
        emit ConditionalOrderPlaced(
            address(account),
            conditionalOrderId,
            keccak256("gelatoTaskId"),
            sETHPERP,
            MARGIN_DELTA,
            SIZE_DELTA,
            TARGET_PRICE,
            IAccount.ConditionalOrderTypes.LIMIT,
            DESIRED_FILL_PRICE,
            true
        );
        vm.prank(account);
        events.emitConditionalOrderPlaced({
            conditionalOrderId: conditionalOrderId,
            gelatoTaskId: keccak256("gelatoTaskId"),
            marketKey: sETHPERP,
            marginDelta: MARGIN_DELTA,
            sizeDelta: SIZE_DELTA,
            targetPrice: TARGET_PRICE,
            conditionalOrderType: IAccount.ConditionalOrderTypes.LIMIT,
            desiredFillPrice: DESIRED_FILL_PRICE,
            reduceOnly: true
        });
    }

    function test_EmitConditionalOrderPlaced_OnlyAccounts() public {
        vm.expectRevert(abi.encodeWithSelector(IEvents.OnlyAccounts.selector));
        events.emitConditionalOrderPlaced({
            conditionalOrderId: 0,
            gelatoTaskId: keccak256("gelatoTaskId"),
            marketKey: sETHPERP,
            marginDelta: MARGIN_DELTA,
            sizeDelta: SIZE_DELTA,
            targetPrice: TARGET_PRICE,
            conditionalOrderType: IAccount.ConditionalOrderTypes.LIMIT,
            desiredFillPrice: DESIRED_FILL_PRICE,
            reduceOnly: true
        });
    }

    function test_EmitConditionalOrderCancelled_Event() public {
        uint256 conditionalOrderId = 0;
        vm.expectEmit(true, true, true, true);
        emit ConditionalOrderCancelled(
            address(account),
            conditionalOrderId,
            keccak256("gelatoTaskId"),
            IAccount
                .ConditionalOrderCancelledReason
                .CONDITIONAL_ORDER_CANCELLED_BY_USER
        );
        vm.prank(account);
        events.emitConditionalOrderCancelled({
            conditionalOrderId: conditionalOrderId,
            gelatoTaskId: keccak256("gelatoTaskId"),
            reason: IAccount
                .ConditionalOrderCancelledReason
                .CONDITIONAL_ORDER_CANCELLED_BY_USER
        });
    }

    function test_EmitConditionalOrderCancelled_OnlyAccounts() public {
        vm.expectRevert(abi.encodeWithSelector(IEvents.OnlyAccounts.selector));
        events.emitConditionalOrderCancelled({
            conditionalOrderId: 0,
            gelatoTaskId: keccak256("gelatoTaskId"),
            reason: IAccount
                .ConditionalOrderCancelledReason
                .CONDITIONAL_ORDER_CANCELLED_BY_USER
        });
    }

    function test_EmitConditionalOrderFilled_Event() public {
        vm.expectEmit(true, true, true, true);
        emit ConditionalOrderFilled(
            address(account),
            0,
            keccak256("gelatoTaskId"),
            FILL_PRICE,
            GELATO_FEE,
            IAccount.PriceOracleUsed.PYTH
        );
        vm.prank(account);
        events.emitConditionalOrderFilled({
            conditionalOrderId: 0,
            gelatoTaskId: keccak256("gelatoTaskId"),
            fillPrice: FILL_PRICE,
            keeperFee: GELATO_FEE,
            priceOracle: IAccount.PriceOracleUsed.PYTH
        });
    }

    function test_EmitConditionalOrderFilled_OnlyAccounts() public {
        vm.expectRevert(abi.encodeWithSelector(IEvents.OnlyAccounts.selector));
        events.emitConditionalOrderFilled({
            conditionalOrderId: 0,
            gelatoTaskId: keccak256("gelatoTaskId"),
            fillPrice: FILL_PRICE,
            keeperFee: GELATO_FEE,
            priceOracle: IAccount.PriceOracleUsed.PYTH
        });
    }
}
