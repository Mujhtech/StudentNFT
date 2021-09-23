//the useed types in the contract
type music_supply = { music_stock : nat ; music_address : address ; music_price : tez ; not_sale : bool ; music_title : string }
type music_storage = (nat, music_supply) map
type return = operation list * music_storage
type music_id = nat

//types that are required for music transfer function 
type transfer_destination =
[@layout:comb]
{
  to_ : address;
  music_id : music_id;
  amount : nat;
}
 
type transfer =
[@layout:comb]
{
  from_ : address;
  txs : transfer_destination list;
}

//address to recieve money from music sales
let publisher_address : address = ("tz1Rm3pAnn6Se4JHaTQ6af3S1bPnjLL5VZbU" : address)

// main function
let main (music_kind_index, music_storage : nat * music_storage) : return =
    //checks if the music exist
  let music_kind : music_supply =
    match Map.find_opt (music_kind_index) music_storage with
    | Some k -> k
    | None -> (failwith "Sorry, We do not stock the requested music!" : music_supply)
  in

  // Check if the music is on sale  
  let () = if music_kind.not_sale = true then
    failwith "Sorry, This music is non-sale!"
  in

  // Check if offer is enough to cover price of music.  
  let () = if Tezos.amount < music_kind.music_price then
    failwith "Sorry, This music is worth more tha that!"
  in

 // Check if the music is in stock.
  let () = if music_kind.music_stock = 0n then
    failwith "Sorry, we dont have any stock of this music."
  in

 //Update our `music_storage` stock levels.
  let music_storage = Map.update
    music_kind_index
    (Some { music_kind with music_stock = abs (music_kind.music_stock - 1n) })
    music_storage
  in

  let tr : transfer = {
    from_ = Tezos.self_address;
    txs = [ {
      to_ = Tezos.sender;
      music_id = abs (music_kind.music_stock - 1n);
      amount = 1n;
    } ];
  } 
  in

  // Transfer FA2 functionality
  let entrypoint : transfer list contract = 
    match ( Tezos.get_entrypoint_opt "%transfer" music_kind.music_address : transfer list contract option ) with
    | None -> ( failwith "Invalid external token contract" : transfer list contract )
    | Some e -> e
  in
 
  let fa2_operation : operation =
    Tezos.transaction [tr] 0tez entrypoint
  in

  // Payout to the Publishers address.
  let receiver : unit contract =
    match (Tezos.get_contract_opt publisher_address : unit contract option) with
    | Some (contract) -> contract
    | None -> (failwith ("Not a contract") : (unit contract))
  in
 
  let payout_operation : operation = 
    Tezos.transaction unit amount receiver 
  in

 ([fa2_operation ; payout_operation], music_storage)
