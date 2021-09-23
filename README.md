# StudentNFT
1. With CameLIGO
2. A smart contract for student to sell the properties

## Storage example

    Map.literal [ 
     (0n, {
       id: 1;
       out_of_stock = false;
       user_address = ("Address of the MusicNFT" : address); 
       property_price = 12mutez;
       sale_status = false;
       property_name = "Wooden Chair";
       property_description = "I love that chair";
     }); 
     (1n, {
       id: 1;
       out_of_stock = false;
       user_address = ("Address of the MusicNFT" : address); 
       property_price = 20mutez;
       sale_status = false;
       property_name = "Shelf";
       property_description = "I love that chair";
     });
     ...
    ]
