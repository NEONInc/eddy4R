##############################################################################################
#' @title Coordinate transformation from CSAT3 body coordinate system to meteorological coordinate system

#' @author Stefan Metzger \email{eddy4R.info@gmail.com} \cr
#' @author Hongyan Luo \email{eddy4R.info@gmail.com}

#' @description Function defintion. Coordinate transformation from CSAT3 body coordinate system to meteorological coordiante system.

#' @param \code{AzSoniInst}  Parameter of class numeric. Azimuth direction against true north in which sonic anemometer installation (transducer array) is pointing [rad]
#' @param \code{AzSoniOfst} Parameter of class integer or numeric.  Azimuth Offset of meteorological x-axis against true north. That is, angle by which sonic data has to be clockwise azimuth-rotated when sonic anemometer body x-axis points perfectly north (azSonic = 0) [rad]
#' @param \code{veloBody}  Variable of class numeric. Data frame containing wind speeds along x-axis (xaxs), y-axis (yaxs),and z-axis (zaxs) in sonic anemometer body coordinate system. For example: \code{veloBody <- data.frame(xaxs=rnorm(20), yaxs=rnorm(20), zaxs=rnorm(20))} [m s-1]


#' @return Wind speed in meteorological coordinate system [m s-1]

#' @references
#' License: Terms of use of the NEON FIU algorithm repository dated 2015-01-16. 

#' @keywords coordinate, sonic anemometer, transformation

#' @examples Currently none

#' @seealso Currently none

#' @export

# changelog and author contributions / copyrights
#   Stefan Metzger (2013-06-27)
#     original creation
#   Stefan Metzger (2015-11-28)
#     re-formualtion as function() to allow packaging
#   Hongyan Luo (2016-05-02)
#     adjust to eddy4R terms
##############################################################################################

def.conv.body.met <- function(
    AzSoniInst,
    AzSoniOfst =  eddy4R.base::def.conv.unit(data=90,unitFrom="deg",unitTo="rad")$dataConv[[1]],
     veloBody 
  ) {

#body coordinate system (BCS)
#geodetic coordinate system (GCS)
#meteorological coordiante system (MCS)

  #Signal   CSAT3 BCS           standard BCS        GCS                 MCS
  #u+       wind from front     wind from front     wind from south     wind from west
  #v+       wind from left      wind from right     wind from west      wind from south
  #w+       wind from below     wind from above     wind from above     wind from below

  #draw axes arrows in direction into which wind is blowing!

#direct transformation from CSAT3 BCS into MCS
  #-> same order of axes, no permutation required
  #-> axes permutation from arbitrary BCS to CSAT3 BCS could be added as a pre-step;
  #-> simple azimuth rotation
  
  
  #determine "body angle" of the sonic
  #the direction against true north in which the sonic x-axis is pointing [radians]
    azSonic <- AzSoniInst - pi
    if(azSonic < 0)  azSonic <- azSonic + 2 * pi  

  #resulting clockwise azimuth rotation angle from BCS to MCS  [radians]
    azMet <- AzSoniOfst - azSonic
    if(azMet < 0)  azMet <- azMet + 2 * pi

  #prepare data.frame for output
    veloMet <- veloBody
    veloMet$xaxs <- NA
    veloMet$yaxs <- NA

  #perform actual rotation
    veloMet$xaxs <- veloBody$xaxs * cos(azMet) - veloBody$yaxs * sin(azMet)  
    veloMet$yaxs <- veloBody$xaxs * sin(azMet) + veloBody$yaxs * cos(azMet)

  #return results
    return(veloMet)
    
}


# #test example
# test <- def.conv.body.met(
#   #"boom angle" of sonic
#   #direction against true north in which the transducer array is pointing [radians]
#     AzSoniInst = eddy4R.base::def.conv.unit(data=189.28,unitFrom="deg",unitTo="rad")$dataConv[[1]],
#   #Offset of MCS x-axis against north
#   #That is, angle by which sonic data has to be clockwise azimuth-rotated 
#   #when BCS x-axis points perfectly north (azSonic == 0) [radians]
#     AzSoniOfst = eddy4R.base::def.conv.unit(data=90,unitFrom="deg",unitTo="rad")$dataConv[[1]],
#   #data.frame with wind speeds u, v, w in BCS
#     veloBody = data.frame(u=ns.data$fst_u, v=ns.data$fst_v, w=ns.data$fst_w)
# )


veloIn01 <- data.frame(xaxs=rnorm(20), yaxs=rnorm(20), zaxs=rnorm(20))
veloIn02 <- veloIn01
dimnames(veloIn02)[[2]] <- c("u", "v", "w")

#test new function
def.conv.body.met(AzSoniInst=60, veloBody=veloIn01)

#test old function
rot_B2M(Psi_boom = 60, BCS_uvw = veloIn02)


