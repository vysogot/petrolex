# frozen_string_literal: true

module Petrolex
  BOARD = %q(
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                                                                                                                                                     .
|QQQQQ--------------------------------------------------------------------------------------------------\    \--------------------------------------------------------
|                                                                                                       |    |  Current tick: top_curr/top_clos           top_name   |
|                                                                                                       |    |                                                       |
|                                                                                                       |    |       Waiting: top_wait         Sim speed: top_spee   |
|                                                                                                       |    |  Being served: top_bein         Fuel cost: top_fuco   |
                                                                                                        |    |  Fully served: top_full        Pumps cost: top_puco   |
                                                                                            _________   |    |       Reserve: top_rese                               |
    XX      XX      XX      XX      XX      XX      XX      XX      XX      XX      XX      |       |   |    |    Fuel given: top_fuel                               |
                                                                                            | PB-95 |   |    |  TT Fuel time: top_ttfu                               |
                                                                                            |       |   |    |  TT Wait time: top_ttwa                               |
    XX      XX      XX      XX      XX      XX      XX      XX      XX      XX      XX      | top_$ |   |    |  AV Fuel time: top_avfu                               |
                                                                                            |       |   |    |  AV Wait time: top_avwa                               |
                                                                                            | $ / l |   |    |  AV Pmp speed: top_avpm                               |
    XX      XX      XX      XX      XX      XX      XX      XX      XX      XX      XX      |       |   |    |     Partially: top_part             Cost: top_ttcost  |
                                                                                            |       |   |    |    Not fueled: top_notf           Income: top_income  |
                                                                                            |_______|   |    |    Cars visit: top_cars          Revenue: top_ttreve  |
    XX      XX      XX      XX      XX      XX      XX      XX      XX      XX      XX     /_________\  |    |                                                       |
--------------------------------------------------------------------------------------------------------TTTTTT--------------------------------------------------------
                                                                                                                                                                     .
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -.
                                                                                                                                                                     .
--------------------------------------------------------------------------------------------------------BBBBBB--------------------------------------------------------
    YY      YY      YY      YY      YY      YY      YY      YY      YY      YY      YY      _________   |    |  Current tick: btm_curr/btm_clos           btm_name   |
                                                                                            |       |   |    |                                                       |
                                                                                            |  O-N  |   |    |       Waiting: btm_wait         Sim speed: btm_spee   |
    YY      YY      YY      YY      YY      YY      YY      YY      YY      YY      YY      |       |   |    |  Being served: btm_bein         Fuel cost: btm_fuco   |
                                                                                            | btm_$ |   |    |  Fully served: btm_full        Pumps cost: btm_puco   |
                                                                                            |       |   |    |       Reserve: btm_rese                               |
    YY      YY      YY      YY      YY      YY      YY      YY      YY      YY      YY      | $ / l |   |    |    Fuel given: btm_fuel                               |
                                                                                            |       |   |    |  TT Fuel time: btm_ttfu                               |
                                                                                            |       |   |    |  TT Wait time: btm_ttwa                               |
    YY      YY      YY      YY      YY      YY      YY      YY      YY      YY      YY      |_______|   |    |  AV Fuel time: btm_avfu                               |
                                                                                           /_________\  |    |  AV Wait time: btm_avwa                               |
                                                                                                        |    |  AV Pmp speed: btm_avpm                               |
|                                                                                                       |    |     Partially: btm_part            Cost: btm_ttcost   |
|                                                                                                       |    |    Not fueled: btm_notf          Income: btm_income   |
|                                                                                                       |    |    Cars visit: btm_cars         Revenue: btm_ttreve   |
|                                                                                                       |    |                                                       |
|                                                                                                       |    |                                                       |
|WWWWW--------------------------------------------------------------------------------------------------/    /--------------------------------------------------------
                                                                                                                                                                     .
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
)
end
