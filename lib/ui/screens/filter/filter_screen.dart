import 'package:another_xlider/another_xlider.dart';
import 'package:another_xlider/models/handler.dart';

import 'package:another_xlider/models/trackbar.dart';
import 'package:code_structure/core/constants/auth_text_feild.dart';

import 'package:code_structure/core/constants/colors.dart';
import 'package:code_structure/core/constants/text_style.dart';
import 'package:code_structure/core/others/base_view_model.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
//******* */

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen>
    with TickerProviderStateMixin {
  double _distanceValue = 50.0;
  List<double> _ageRangeValues = [18.0, 30.0];
  String _selectedGender = 'Both';
  String _currentLocation = 'Select current location';
  double? _currentLatitude;
  double? _currentLongitude;

  void _updateLocation(String location, {double? lat, double? lng}) {
    setState(() {
      _currentLocation = location;
      _currentLatitude = lat;
      _currentLongitude = lng;
    });
  }

  void _applyFilters() {
    final filters = {
      'minAge': _ageRangeValues[0].toInt(),
      'maxAge': _ageRangeValues[1].toInt(),
      'distance': _distanceValue.toInt(),
      'gender': _selectedGender,
      'latitude': _currentLatitude,
      'longitude': _currentLongitude,
      'location': _currentLocation,
    };

    // Close screen and return filters
    Navigator.pop(context, filters);
  }

  ///
  ///
  ///
  @override
  Widget build(BuildContext context) {
    TabController(length: 3, vsync: this);
    return ChangeNotifierProvider(
      create: (context) => BaseViewModel(),
      child: Consumer<BaseViewModel>(
        builder: (context, model, child) => DefaultTabController(
          length: 3,
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  50.verticalSpace,

                  ///  header
                  _header(),
                  10.verticalSpace,
                  Divider(),

                  50.verticalSpace,
                  _tababr(),
                  30.verticalSpace,
                  //  _Location(),
                  _selectLocation(),
                  30.verticalSpace,
                  //// selecting age and distance range
                  _buildFilterContent(),
                  30.verticalSpace,
                  _buildApplyButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Filter',
            style: style25B.copyWith(
                fontSize: 34, fontWeight: FontWeight.w700, color: headingColor),
          ),
          Text(
            'Done',
            style: style25.copyWith(fontSize: 17.sp, color: indicatorColor),
          )
        ],
      ),
    );
  }

  _tababr() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Show me ",
          style: style17.copyWith(
            color: blackColor,
          ),
        ),
        20.verticalSpacingDiameter,
        Container(
          height: 50.h,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1), color: tabBarColor),

          ///
          ///   tab bar
          ///
          child: TabBar(
            labelStyle: TextStyle(color: whiteColor),
            labelColor: whiteColor,
            unselectedLabelColor: tabBarTextColor,

            tabAlignment: TabAlignment.start,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(0),
              gradient: LinearGradient(
                colors: [lightPinkColor, lightOrangeColor],
              ),
            ),
            isScrollable: true,
            onTap: (value) {
              switch (value) {
                case 0:
                  _selectedGender = 'Male';
                case 1:
                  _selectedGender = 'Female';
                case 2:
                  _selectedGender = 'Both';
                default:
                  _selectedGender = 'Both';
              }
            },
            //  labelPadding: EdgeInsets.symmetric(horizontal: 30),
            tabs: [
              ///
              ///  tab 1
              ///
              Container(
                height: 50.h,
                child: Tab(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      'Guys',
                      style: style25.copyWith(
                          fontSize: 17.sp,
                          color: tabBarTextColor,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                ),
              ),

              ///
              /// tab 2
              ///
              Tab(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    'Girls',
                    style: style25.copyWith(
                        fontSize: 17.sp,
                        color: tabBarTextColor,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ),

              ///
              /// tab 3
              ///
              Tab(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    'Both',
                    style: style25.copyWith(
                        fontSize: 17.sp,
                        color: tabBarTextColor,
                        fontWeight: FontWeight.w400),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _Location() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Location",
          style: style17.copyWith(
            color: blackColor,
          ),
        ),
        20.verticalSpacingDiameter,
        TextFormField(
          decoration: authFieldDecoration.copyWith(),
        ),
      ],
    );
  }

  Widget _buildFilterContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        30.verticalSpace,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Distance',
              style: style17.copyWith(color: blackColor),
            ),
            Text(
              '${_distanceValue.toInt()} km',
              style: style25.copyWith(
                  fontSize: 17,
                  color: lightGreyColor3,
                  fontWeight: FontWeight.w300),
            ),
          ],
        ),
        30.verticalSpace,
        FlutterSlider(
          values: [_distanceValue],
          max: 100,
          min: 0,
          trackBar: FlutterSliderTrackBar(
            activeTrackBarHeight: 8.4,
            inactiveTrackBarHeight: 8.4,
            activeTrackBar: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              gradient: LinearGradient(
                colors: [lightPinkColor, lightOrangeColor],
              ),
            ),
            inactiveTrackBar: BoxDecoration(
              color: Colors.grey[300], // Adjust as needed
            ),
          ),
          handler: FlutterSliderHandler(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [lightPinkColor, lightOrangeColor],
              ),
            ),
            child: Container(
              padding: EdgeInsets.all(4), // Adjust padding for circle size
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [lightPinkColor, lightOrangeColor],
                  ),
                ),
              ),
            ),
          ),
          onDragging: (handlerIndex, lowerValue, upperValue) {
            _distanceValue = lowerValue;
            setState(() {});
          },
        ),
        30.verticalSpace,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Age range',
              style: style17.copyWith(color: blackColor),
            ),
            Text(
              '${_ageRangeValues[0].toInt()} - ${_ageRangeValues[1].toInt()}',
              style: style25.copyWith(
                  fontSize: 17,
                  color: lightGreyColor3,
                  fontWeight: FontWeight.w300),
            ),
          ],
        ),
        30.verticalSpace,
        FlutterSlider(
          values: _ageRangeValues,
          max: 50,
          min: 18,
          rangeSlider: true,
          trackBar: FlutterSliderTrackBar(
            activeTrackBarHeight: 8.4,
            inactiveTrackBarHeight: 8.4,
            activeTrackBar: BoxDecoration(
              gradient: LinearGradient(
                colors: [lightPinkColor, lightOrangeColor],
              ),
            ),
            inactiveTrackBar: BoxDecoration(
              color: Colors.grey[300], // Adjust as needed
            ),
          ),
          handler: FlutterSliderHandler(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [lightPinkColor, lightOrangeColor],
              ),
            ),
            child: Container(
              padding: EdgeInsets.all(4), // Adjust padding for circle size
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [lightPinkColor, lightOrangeColor],
                  ),
                ),
              ),
            ),
          ),
          rightHandler: FlutterSliderHandler(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [lightPinkColor, lightOrangeColor],
              ),
            ),
            child: Container(
              padding: EdgeInsets.all(4), // Adjust padding for circle size
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [lightPinkColor, lightOrangeColor],
                  ),
                ),
              ),
            ),
          ),
          onDragging: (handlerIndex, lowerValue, upperValue) {
            _ageRangeValues = [lowerValue, upperValue];
            setState(() {});
          },
        ),
        SizedBox(height: 24),
      ],
    );
  }

  //***************   container for selecting location    ****************
  ///
  _selectLocation() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        // Use InkWell for tap detection
        onTap: () {
          _showLocationBottomSheet(context);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Current location ($_currentLocation)'),
            Icon(Icons.send),
          ],
        ),
      ),
    );
  }

  ///                  location selection using bottom sheet
  ///
  void _showLocationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.my_location),
                title: Text('Use current location'),
                onTap: () async {
                  Navigator.pop(context);
                  await _getCurrentLocation();
                },
              ),
              ListTile(
                leading: Icon(Icons.search),
                title: Text('Search location'),
                onTap: () {
                  Navigator.pop(context);
                  _showSearchLocationDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '${place.locality}, ${place.country}';
        _updateLocation(
          address,
          lat: position.latitude,
          lng: position.longitude,
        );
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _showSearchLocationDialog(BuildContext context) {
    final TextEditingController _searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Search Location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Enter location',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('SEARCH'),
              onPressed: () async {
                if (_searchController.text.isNotEmpty) {
                  try {
                    List<Location> locations =
                        await locationFromAddress(_searchController.text);
                    if (locations.isNotEmpty) {
                      Location location = locations[0];
                      List<Placemark> placemarks =
                          await placemarkFromCoordinates(
                        location.latitude,
                        location.longitude,
                      );

                      if (placemarks.isNotEmpty) {
                        Placemark place = placemarks[0];
                        _updateLocation(
                          _searchController.text,
                          lat: location.latitude,
                          lng: location.longitude,
                        );
                      }
                    }
                  } catch (e) {
                    print('Error searching location: $e');
                  }
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildApplyButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: indicatorColor,
          padding: EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: _applyFilters,
        child: Text(
          'Apply Filters',
          style: style17.copyWith(color: whiteColor),
        ),
      ),
    );
  }
}
