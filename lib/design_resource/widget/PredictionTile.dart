import 'package:flutter/material.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import 'package:shareride_app/DataProvider/appData.dart';
import 'package:shareride_app/dataModels/address.dart';
import 'package:shareride_app/dataModels/prediction.dart';
import 'package:shareride_app/design_resource/widget/ProgressDialog.dart';
import 'package:shareride_app/global_variables.dart';
import 'package:shareride_app/helper/Network_Request.dart';

import '../app_colors.dart';

class PredictionTile extends StatelessWidget {

  final Prediction prediction;
  PredictionTile({this.prediction});

  void getPlaceDetails(String placeID, context) async{

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => ProgressDialog(status: 'Please Wait...',)
    );
    String url = 'https://maps.googleapis.com/maps/api/place/details/json?placeid=$placeID&key=$mapKey';

    var response = await RequestHelper.getRequest(url);

    Navigator.pop(context);

    if(response == 'failed'){
      return;
    }

    if(response['status'] == 'OK'){

      Address thisPlace = Address();

      thisPlace.placeName = response['result']['name'];
      thisPlace.placeId = placeID;
      thisPlace.latitude = response['result']['geometry']['location']['lat'];
      thisPlace.longitude = response['result']['geometry']['location']['lng'];

      Provider.of<AppData>(context, listen: false).updateDestinationAddress(thisPlace);

      Navigator.pop(context, 'getDirection');
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (){
        getPlaceDetails(prediction.placeId, context);
      },
      style: TextButton.styleFrom(padding: EdgeInsets.all(0)),
      child: Container(
        child: Column(
          children: <Widget>[
            SizedBox(height: 8,),
            Row(
              children: <Widget>[
                Icon(OMIcons.locationOn, color: AppColors.colorDimText,),
                SizedBox(width: 12,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(prediction.mainText,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 16
                        ),
                      ),
                      SizedBox(width: 2,),
                      Text(prediction.secondaryText,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.colorDimText,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 8,),
          ],
        ),
      ),
    );
  }
}