% Improved Electricity Market Auction Model

% Parameters
int: N;  % Number of generators
int: M;  % Number of time units (typically 24 hours)

array[1..M] of int: demand;  % Energy demanded for each hour (KW)
array[1..N, 1..M] of int: capacity;  % Production capacity of each generator at each hour
array[1..N] of int: price;  % Selling price of each generator

% Variables
array[1..N, 1..M] of var int: purchase;  % KW purchased from generator i at hour j
var int: purchase_price;  % Purchase price (maximum price among selected generators)
array[1..N] of var bool: generator_used;  % Whether generator i is used at all

% Constraints
% Domain constraints for purchases
constraint forall(i in 1..N, j in 1..M) (
  0 <= purchase[i,j] /\ purchase[i,j] <= capacity[i,j]
);

% Demand satisfaction constraints
constraint forall(j in 1..M) (
  sum(i in 1..N) (purchase[i,j]) == demand[j]
);

% Link generator_used with purchases
constraint forall(i in 1..N) (
  generator_used[i] <-> (sum(j in 1..M) (purchase[i,j]) > 0)
);

% Purchase price constraint
constraint purchase_price = max([if generator_used[i] then price[i] else 0 endif | i in 1..N]);

% Implied constraint: prefer cheaper generators
% If generator j is more expensive than generator i, only use j if i is at capacity
constraint forall(i,j in 1..N where price[i] < price[j]) (
  forall(h in 1..M) (
    purchase[j,h] > 0 -> purchase[i,h] == capacity[i,h]
  )
);

% Objective function
solve :: int_search(purchase, input_order, indomain_min, complete)
     minimize purchase_price;



% Output
output [
  "Purchase Matrix:\n",
  show2d(purchase),
  "\nGenerators Used: ", show(generator_used),
  "\nPurchase Price: ", show(purchase_price), "\n"
];