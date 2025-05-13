import 'package:flutter/material.dart';
import 'package:unicorn_app_frontend/views/authentication/register/terms_strings.dart';

class TermsAndAgreementSheet extends StatelessWidget {
  const TermsAndAgreementSheet({super.key});

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: TermsStrings.sectionTitleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: TermsStrings.smallSpacing),
        Text(
          content,
          style: TextStyle(fontSize: TermsStrings.contentFontSize),
        ),
        SizedBox(height: TermsStrings.spacing),
      ],
    );
  }

  Widget _buildListSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: TermsStrings.sectionSubtitleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: TermsStrings.smallSpacing),
        ...items.map((item) => Padding(
          padding: EdgeInsets.only(bottom: TermsStrings.bottomPadding),
          child: Text(
            item,
            style: TextStyle(fontSize: TermsStrings.contentFontSize),
          ),
        )),
        SizedBox(height: TermsStrings.spacing),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: TermsStrings.sheetInitialSize,
      minChildSize: TermsStrings.sheetMinSize,
      maxChildSize: TermsStrings.sheetMaxSize,
      expand: false,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        child: Padding(
          padding: EdgeInsets.all(TermsStrings.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    TermsStrings.title,
                    style: TextStyle(
                      fontSize: TermsStrings.titleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: TermsStrings.spacing),
              _buildSection(TermsStrings.section1Title, TermsStrings.section1Content),
              _buildSection(TermsStrings.section2Title, ''),
              _buildListSection(TermsStrings.section2Subtitle, TermsStrings.section2Data),
              _buildListSection(TermsStrings.section2UsageTitle, TermsStrings.section2Usage),
              _buildSection(TermsStrings.section3Title, TermsStrings.section3Content),
              _buildSection(TermsStrings.section4Title, ''),
              ...TermsStrings.section4Content.map((content) => Padding(
                padding: EdgeInsets.only(bottom: TermsStrings.bottomPadding),
                child: Text(
                  content,
                  style: TextStyle(fontSize: TermsStrings.contentFontSize),
                ),
              )),
              SizedBox(height: TermsStrings.spacing),
              _buildSection(TermsStrings.section5Title, ''),
              _buildListSection(TermsStrings.section5Subtitle, TermsStrings.section5Rights),
              Text(
                TermsStrings.section5Contact,
                style: TextStyle(fontSize: TermsStrings.contentFontSize),
              ),
              SizedBox(height: TermsStrings.spacing),
              Text(
                TermsStrings.agreementText,
                style: TextStyle(
                  fontSize: TermsStrings.agreementFontSize,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showTermsAndAgreement(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const TermsAndAgreementSheet(),
  );
} 