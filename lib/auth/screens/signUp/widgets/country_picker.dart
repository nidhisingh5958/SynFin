import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:SynFin/common/components/colors.dart';

class CustomCountryPicker extends StatefulWidget {
  final Function(Country) onSelectCountry;
  final Country? initialCountry;
  final TextStyle? countryNameStyle;
  final TextStyle? countryCodeStyle;
  final Color? searchBarColor;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final TextStyle? searchTextStyle;
  final String? searchHintText;
  final BoxDecoration? flagDecoration;

  const CustomCountryPicker({
    super.key,
    required this.onSelectCountry,
    this.initialCountry,
    this.countryNameStyle,
    this.countryCodeStyle,
    this.searchBarColor,
    this.backgroundColor,
    this.borderRadius,
    this.searchTextStyle,
    this.searchHintText,
    this.flagDecoration,
  });

  @override
  State<CustomCountryPicker> createState() => _CustomCountryPickerState();
}

class _CustomCountryPickerState extends State<CustomCountryPicker> {
  final TextEditingController _searchController = TextEditingController();
  List<Country> _filteredCountries = [];
  List<Country> _allCountries = [];

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  void _loadCountries() {
    // Use the country_picker package to get all countries
    final List<Country> countries = CountryService().getAll();
    setState(() {
      _allCountries = countries;
      _filteredCountries = countries;
    });
  }

  void _filterCountries(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredCountries = _allCountries;
      });
      return;
    }

    final List<Country> filtered = _allCountries
        .where(
          (country) =>
              country.name.toLowerCase().contains(query.toLowerCase()) ||
              country.phoneCode.contains(query) ||
              country.countryCode.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    setState(() {
      _filteredCountries = filtered;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: widget.backgroundColor ?? Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            children: [
              // Search bar
              Container(
                color: widget.searchBarColor ?? Colors.grey[100],
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterCountries,
                        style:
                            widget.searchTextStyle ??
                            TextStyle(fontSize: 18, color: black),
                        decoration: InputDecoration(
                          hintText: widget.searchHintText ?? 'Search country',
                          hintStyle:
                              widget.searchTextStyle?.copyWith(
                                color: Colors.grey,
                              ) ??
                              TextStyle(fontSize: 18, color: Colors.grey),
                          prefixIcon: const Icon(Icons.search),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        cursorColor: widget.searchTextStyle?.color ?? black,
                        cursorHeight: 18,
                        textInputAction: TextInputAction.search,
                        onSubmitted: (value) {
                          _filterCountries(value);
                        },
                        textAlignVertical: TextAlignVertical.center,
                        textAlign: TextAlign.start,
                        textCapitalization: TextCapitalization.words,
                        autocorrect: true,
                        enableSuggestions: true,
                        keyboardType: TextInputType.text,
                      ),
                    ),
                  ],
                ),
              ),

              // Country list
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredCountries.length,
                  itemBuilder: (context, index) {
                    final country = _filteredCountries[index];
                    return _buildCountryTile(country);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountryTile(Country country) {
    return InkWell(
      onTap: () {
        widget.onSelectCountry(country);
        Navigator.pop(context);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!, width: 1),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            // Flag
            Container(
              decoration: widget.flagDecoration,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                country.flagEmoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(width: 16),

            // Country name
            Expanded(
              child: Text(
                country.name,
                style:
                    widget.countryNameStyle ??
                    TextStyle(fontSize: 16, color: black),
              ),
            ),

            // Country code
            Text(
              '+${country.phoneCode}',
              style:
                  widget.countryCodeStyle ??
                  TextStyle(
                    fontSize: 16,
                    color: grey600,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper function to show the custom country picker
void showCustomCountryPicker({
  required BuildContext context,
  required Function(Country) onSelect,
  Country? initialCountry,
  TextStyle? countryNameStyle,
  TextStyle? countryCodeStyle,
  Color? searchBarColor,
  Color? backgroundColor,
  BorderRadius? borderRadius,
  TextStyle? searchTextStyle,
  String? searchHintText,
  BoxDecoration? flagDecoration,
}) {
  showDialog(
    context: context,
    builder: (context) => CustomCountryPicker(
      onSelectCountry: onSelect,
      initialCountry: initialCountry,
      countryNameStyle: countryNameStyle,
      countryCodeStyle: countryCodeStyle,
      searchBarColor: searchBarColor,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      searchTextStyle: searchTextStyle,
      searchHintText: searchHintText,
      flagDecoration: flagDecoration,
    ),
  );
}
