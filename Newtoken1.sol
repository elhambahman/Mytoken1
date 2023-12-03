// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts@5.0.0/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@5.0.0/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts@5.0.0/token/ERC20/extensions/ERC20Pausable.sol";
import "@openzeppelin/contracts@5.0.0/access/Ownable.sol";

contract NewToken is ERC20, ERC20Burnable, ERC20Pausable, Ownable {
event TokenPurchased(address indexed buyer, uint256 amount);
mapping(address => uint256) public shares;

address[] public buyers;
address public wallet;

 constructor() ERC20("NewToken", "TEK") Ownable(wallet) {
       _mint(msg.sender, 150000000 * 10 ** decimals());
   } 

   function pause() public onlyOwner {
       _pause();
   }

   function unpause() public onlyOwner {
       _unpause();
   }

   function mint(address to, uint256 amount) public onlyOwner {
       _mint(to, amount);
   }

 
function buyTokens(address buyer, uint256 amount) public {
   require(amount <= totalSupply(), "Not enough tokens available");
   _burn(msg.sender, amount);
   shares[buyer] += amount;
   emit TokenPurchased(buyer, amount);
}

function issueToken(address receiver, uint256 amount) public onlyOwner {
   _mint(receiver, amount);
}

function setWallet(address _wallet) public onlyOwner {
   wallet = _wallet;
}
function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
   uint256 transferAmount = amount * 99 / 100; // مقدار انتقال برای کیف پول والت
   super.transfer(wallet, amount - transferAmount); // انتقال 1 درصد مقدار خرید به کیف پول والت
   uint256 remainingAmount = transferAmount;
   for (uint256 i = 0; i < buyers.length; i++) {
       uint256 share = shares[buyers[i]];
       uint256 shareAmount = transferAmount * share / totalSupply();
       super.transfer(buyers[i], shareAmount); // تقسیم مقدار باقیمانده  بین خریداران بر اساس سهم
       remainingAmount -= shareAmount;
   }
   super.transfer(recipient, remainingAmount); // انتقال مقدار باقیمانده به کیف پول درخواست کننده
   return true;
}


   function _update(address from, address to, uint256 value)
       internal
       override(ERC20, ERC20Pausable)
   {
       super._update(from, to, value);
   }
}
