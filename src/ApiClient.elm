module ApiClient exposing
    ( DomainDetails
    , DomainDetailsResult
    , EndingSoon
    , EndingSoonDomain
    , EndingSoonResult
    , getDomainDetails
    , getEndingSoon
    )

import Http
import Json.Decode as D



-- api global


baseUrl =
    -- "https://www.namebase.io/api" sends bad cors headers
    "http://nb-proxy.tasuki/api"


endingSoonPerPage =
    100



-- get "ending soon"


type alias EndingSoonDomain =
    { name : String
    , revealAt : Int
    , bids : Int
    }


type alias EndingSoon =
    { lastBlock : Int
    , domains : List EndingSoonDomain
    }


type alias EndingSoonResult =
    Result Http.Error EndingSoon


getEndingSoon : (EndingSoonResult -> msg) -> Int -> Cmd msg
getEndingSoon ctor count =
    Http.get
        { url =
            baseUrl
                ++ "/domains/ending-soon/"
                ++ (count * endingSoonPerPage |> String.fromInt)
        , expect = Http.expectJson ctor endingSoonDecoder
        }


endingSoonDecoder : D.Decoder EndingSoon
endingSoonDecoder =
    D.map2 EndingSoon
        (D.field "height" D.int)
        (D.field "domains" domainsDecoder)


domainsDecoder : D.Decoder (List EndingSoonDomain)
domainsDecoder =
    D.list <|
        D.map3 EndingSoonDomain
            (D.field "name" D.string)
            (D.field "reveal_block" D.int)
            (D.field "total_number_bids" D.int)



-- get "domain details"


type alias Bid =
    { stakeAmount : Int }


type alias DomainDetails =
    { name : String
    , revealAt : Int
    , highestBid : Int
    , lastBlock : Int
    , bids : List Bid
    }


type alias DomainDetailsResult =
    Result Http.Error DomainDetails


getDomainDetails : (DomainDetailsResult -> msg) -> String -> Cmd msg
getDomainDetails ctor domain =
    Http.get
        { url = baseUrl ++ "/domains/get/" ++ domain
        , expect = Http.expectJson ctor domainDetailsDecoder
        }


stringToInt : D.Decoder String -> D.Decoder Int
stringToInt =
    D.map String.toInt >> D.map (Maybe.withDefault 0)


bidsDecoder : D.Decoder (List Bid)
bidsDecoder =
    D.list <| D.map Bid (D.field "stake_amount" D.string |> stringToInt)


domainDetailsDecoder : D.Decoder DomainDetails
domainDetailsDecoder =
    D.map5 DomainDetails
        (D.field "name" D.string)
        (D.field "revealBlock" D.int)
        (D.field "highestStakeAmount" D.int)
        (D.field "height" D.int)
        (D.field "bids" bidsDecoder)
