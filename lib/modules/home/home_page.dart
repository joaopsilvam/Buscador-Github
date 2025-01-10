import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_bloc.dart';

class HomePage extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: isDesktop
            ? _buildDesktopLayout(context, screenWidth)
            : _buildMobileLayout(context, screenWidth),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, double screenWidth) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/logo.png',
          width: screenWidth * 0.3,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 40),
        Container(
          width: screenWidth * 0.6,
          child: Row(
            children: [
              Expanded(child: _buildSearchField(context, screenWidth)),
              SizedBox(width: 12),
              _buildSearchButton(context, screenWidth * 0.15),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, double screenWidth) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/logo.png',
          width: screenWidth * 0.7,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 20),
        Container(
          width: screenWidth * 0.9,
          child: _buildSearchField(context, screenWidth),
        ),
        SizedBox(height: 50), // Espaçamento entre a barra de busca e o botão
        Container(
          width: screenWidth * 0.9,
          child: _buildSearchButton(context, screenWidth * 0.9),
        ),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context, double screenWidth) {
    final isDesktop = screenWidth > 800;

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return state.suggestions;
            }
            return state.suggestions.where((suggestion) => suggestion
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase()));
          },
          onSelected: (String selection) {
            _controller.text = selection;
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            _controller.addListener(() {
              controller.text = _controller.text;
              controller.selection = _controller.selection;
            });
            return TextField(
              controller: _controller,
              focusNode: focusNode,
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  Modular.get<HomeBloc>().add(SaveSearchEvent(value));
                  Modular.to.pushNamed('/profile/$value');
                }
              },
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: Color.fromARGB(100, 0, 0, 92),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Color.fromARGB(50, 0, 0, 92),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(
                    color: Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(
                    color: Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(
                    color: Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Color.fromARGB(100, 0, 0, 92),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                child: Container(
                  width: isDesktop ? screenWidth * 0.6 : screenWidth * 0.9,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final suggestion = options.elementAt(index);
                      return ListTile(
                        title: Text(
                          suggestion,
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                        onTap: () {
                          _controller.text = suggestion;
                          onSelected(suggestion);
                          Modular.get<HomeBloc>()
                              .add(SaveSearchEvent(suggestion));
                          Modular.to.pushNamed('/profile/$suggestion');
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchButton(BuildContext context, double width) {
    return ElevatedButton(
      onPressed: () {
        final username = _controller.text.trim();
        if (username.isNotEmpty) {
          Modular.get<HomeBloc>().add(SaveSearchEvent(username));
          Modular.to.pushNamed('/profile/$username');
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF8C19D2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        minimumSize: Size(width, 54),
      ),
      child: Text(
        'Search',
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
