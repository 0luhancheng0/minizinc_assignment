int: NL; % number of loaders
         % number of rails = NL for parts A-E
         % number of rails = (NL + 1) div 2 for part F
opt bool: partF; % are we solving stage F
set of int: LOADER = 1..NL;

enum CARGO; 
array[CARGO] of int: size; % size in 10000 tonne units

int: makespan; % maximum time considered.
set of int: TIME = 0..makespan;

enum SHIP; % set of ships
array[CARGO] of SHIP: ship; % which ship takes stockpile
array[SHIP] of TIME: arrival;  % when ship arrives

int: len; % length of pad
set of int: POS = 0..len; 

int: build_time; % time to build 1 unit (10000 tonnnes)
int: load_time; % time to load 1 unit
int: load_speed; % time for loader to move 1 unit

array[CARGO] of var POS: westx;
array[CARGO] of var POS: eastx;
array[CARGO] of var TIME: build;
array[CARGO] of var TIME: endbuild;
array[CARGO] of var TIME: load;
array[CARGO] of var TIME: finish;
array[CARGO] of var LOADER: which;

include "globals.mzn";

% represent the total time span for any cargo to be loaded
array[CARGO] of TIME: total_load_time = [load_time * size[c] | c in CARGO];


% set the value for eastx, endbuild and finish
constraint forall(c in CARGO)(
    eastx[c] = westx[c] + size[c] 
    /\ endbuild[c] = build[c] + build_time * size[c] 
    /\ finish[c] = load[c] + total_load_time[c]
);

% make sure the loading start after the entire cargo is built
constraint forall(c in CARGO)(
    load[c] >= build[c] + size[c] * build_time
);

% make sure cargo does not overlap in space-time on the pad
constraint diffn(
    westx, 
    build,
    size,
    [finish[c] - build[c] | c in CARGO]
);

% part B, make sure any loader can only load one cargo at a time
constraint forall(l in LOADER)(
    disjunctive(
        [load[c] | c in CARGO],   
        [total_load_time[c] * (which[c] = l) | c in CARGO]
    )
);

% part D, make sure there is sufficient time intervel for loader to move between loading event 
array[1..card(CARGO)] of var CARGO: cargo_load_order;
constraint forall(i in 1..card(CARGO))(
    let {
        array[int] of var int: order = arg_sort(load);
    } in
    cargo_load_order[i] = to_enum(CARGO, order[i])
);
constraint forall(i in 1..length(cargo_load_order)-1)(
    load[cargo_load_order[i+1]] - finish[cargo_load_order[i]] >= abs(westx[cargo_load_order[i+1]] - eastx[cargo_load_order[i]]) * load_speed
);
% make sure loading start after designated ship's arrival
constraint forall(c in CARGO)(
    load[c] >= arrival[ship[c]]
);
% part C, make sure there is only one cargo loading for any ship
constraint forall(s in SHIP)(
    disjunctive(
        [load[c] | c in CARGO],
        [total_load_time[c] * (ship[c] = s) | c in CARGO]
    )
);


output 
["westx  = array1d(CARGO,\(westx));\n"] ++
["eastx  = array1d(CARGO,\(eastx));\n"] ++
["build  = array1d(CARGO,\(build));\n"] ++
["endbuild  = array1d(CARGO,\(endbuild));\n"] ++
["load  = array1d(CARGO,\(load));\n"] ++
["finish  = array1d(CARGO,\(finish));\n"] ++
["which  = array1d(CARGO,\(which));\n"] 
;

% include "../viz/cargo_viz.mzn";
% output [cargo_viz(westx,eastx,build,endbuild,load,finish,which)];
