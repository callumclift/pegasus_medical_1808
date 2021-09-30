import 'package:flutter/material.dart';
import 'package:pegasus_medical_1808/models/authentication_model.dart';
import 'package:pegasus_medical_1808/shared/global_config.dart';
import 'package:pegasus_medical_1808/widgets/app_bar_gradient.dart';
import 'package:pegasus_medical_1808/widgets/gradient_button.dart';
import 'package:provider/provider.dart';

class TermsConditionsPage extends StatefulWidget {


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TermsConditionsPageState();
  }
}

class _TermsConditionsPageState extends State<TermsConditionsPage> {
  _acceptTerms() async {
    await context.read<AuthenticationModel>().setTermsAccepted();
  }

  _declineTerms() {
    context.read<AuthenticationModel>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double deviceHeight = MediaQuery.of(context).size.width;

    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          flexibleSpace: AppBarGradient(),
          title: FittedBox(fit:BoxFit.fitWidth,
              child: Text('Terms & Conditions', style: TextStyle(fontWeight: FontWeight.bold),)),
        ),
        body: Consumer<AuthenticationModel>(
          builder: (context, model, child) {
            return model.isLoading ? Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(blueDesign),
              ),
            )
                : SingleChildScrollView(
                child: Column(children: <Widget>[
                  Container(padding: EdgeInsets.all(10), width: deviceWidth, child: Image.asset(
                    'assets/images/pegasusLogo.png',
                    height: deviceHeight * 0.25,
                  ),),
                  Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(border: Border.all(color: greyDesign1)), width: deviceWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('These terms and conditions ("Terms", "Agreement") are an agreement between Pegasus Medical (1808) Ltd ("Pegasus Medical (1808) Ltd", "us", "we" or "our") and you ("User", "you" or "your"). This Agreement sets forth the general terms and conditions of your use of the Pegasus Medical (1808) mobile application and any of its products or services (collectively, "Mobile Application" or "Services")', style: TextStyle(color: bluePurple)),
                        SizedBox(height: 10,),
                        Text('Accounts and membership', style: TextStyle(fontWeight: FontWeight.bold, color: bluePurple, fontSize: 16),),
                        SizedBox(height: 5,),
                        Text('If you create an account in the Mobile Application, you are responsible for maintaining the security of your account and you are fully responsible for all activities that occur under the account and any other actions taken in connection with it. We may monitor and review new accounts before you may sign in and use our Services. Providing false contact information of any kind may result in the termination of your account. You must immediately notify us of any unauthorized uses of your account or any other breaches of security. We will not be liable for any acts or omissions by you, including any damages of any kind incurred as a result of such acts or omissions. We may suspend, disable, or delete your account (or any part thereof) if we determine that you have violated any provision of this Agreement or that your conduct or content would tend to damage our reputation and goodwill. If we delete your account for the foregoing reasons, you may not re-register for our Services. We may block your email address and Internet protocol address to prevent further registration.', style: TextStyle(color: bluePurple)),
                        SizedBox(height: 10,),
                        Text('User content', style: TextStyle(fontWeight: FontWeight.bold, color: bluePurple, fontSize: 16),),
                        SizedBox(height: 5,),
                        Text('We do not own any data, information or material ("Content") that you submit in the Mobile Application in the course of using the Service. You shall have sole responsibility for the accuracy, quality, integrity, legality, reliability, appropriateness, and intellectual property ownership or right to use of all submitted Content. We may monitor and review Content in the Mobile Application submitted or created using our Services by you. Unless specifically permitted by you, your use of the Mobile Application does not grant us the license to use, reproduce, adapt, modify, publish or distribute the Content created by you or stored in your user account for commercial, marketing or any similar purpose. But you grant us permission to access, copy, distribute, store, transmit, reformat, display and perform the Content of your user account solely as required for the purpose of providing the Services to you. Without limiting any of those representations or warranties, we have the right, though not the obligation, to, in our own sole discretion, refuse or remove any Content that, in our reasonable opinion, violates any of our policies or is in any way harmful or objectionable.', style: TextStyle(color: bluePurple)),
                        SizedBox(height: 10,),
                        Text('Accuracy of information', style: TextStyle(fontWeight: FontWeight.bold, color: bluePurple, fontSize: 16),),
                        SizedBox(height: 5,),

                        Text('Occasionally there may be information in the Mobile Application that contains typographical errors, inaccuracies or omissions that may relate to availability, promotions and offers. We reserve the right to correct any errors, inaccuracies or omissions, and to change or update information or cancel orders if any information in the Mobile Application or on any related Service is inaccurate at any time without prior notice (including after you have submitted your order). We undertake no obligation to update, amend or clarify information in the Mobile Application including, without limitation, pricing information, except as required by law. No specified update or refresh date applied in the Mobile Application should be taken to indicate that all information in the Mobile Application or on any related Service has been modified or updated.', style: TextStyle(color: bluePurple)),
                        SizedBox(height: 10,),
                        Text('Backups', style: TextStyle(fontWeight: FontWeight.bold, color: bluePurple, fontSize: 16),),
                        SizedBox(height: 5,),

                        Text('We perform regular backups of the Content and will do our best to ensure completeness and accuracy of these backups. In the event of the hardware failure or data loss we will restore backups automatically to minimize the impact and downtime.', style: TextStyle(color: bluePurple)),
                        SizedBox(height: 10,),
                        Text('Prohibited uses', style: TextStyle(fontWeight: FontWeight.bold, color: bluePurple, fontSize: 16),),
                        SizedBox(height: 5,),

                        Text('In addition to other terms as set forth in the Agreement, you are prohibited from using the Mobile Application or its Content: (a) for any unlawful purpose; (b) to solicit others to perform or participate in any unlawful acts; (c) to violate any international, federal, provincial or state regulations, rules, laws, or local ordinances; (d) to infringe upon or violate our intellectual property rights or the intellectual property rights of others; (e) to harass, abuse, insult, harm, defame, slander, disparage, intimidate, or discriminate based on gender, sexual orientation, religion, ethnicity, race, age, national origin, or disability; (f) to submit false or misleading information; (g) to upload or transmit viruses or any other type of malicious code that will or may be used in any way that will affect the functionality or operation of the Service or of any related mobile application, other mobile applications, or the Internet; (h) to collect or track the personal information of others; (i) to spam, phish, pharm, pretext, spider, crawl, or scrape; (j) for any obscene or immoral purpose; or (k) to interfere with or circumvent the security features of the Service or any related mobile application, other mobile applications, or the Internet. We reserve the right to terminate your use of the Service or any related mobile application for violating any of the prohibited uses.', style: TextStyle(color: bluePurple)),
                        SizedBox(height: 10,),
                        Text('Intellectual property rights', style: TextStyle(fontWeight: FontWeight.bold, color: bluePurple, fontSize: 16),),
                        SizedBox(height: 5,),

                        Text('This Agreement does not transfer to you any intellectual property owned by Pegasus Medical (1808) Ltd or third-parties, and all rights, titles, and interests in and to such property will remain (as between the parties) solely with Pegasus Medical (1808) Ltd. All trademarks, service marks, graphics and logos used in connection with our Mobile Application or Services, are trademarks or registered trademarks of Pegasus Medical (1808) Ltd or Pegasus Medical (1808) Ltd licensors. Other trademarks, service marks, graphics and logos used in connection with our Mobile Application or Services may be the trademarks of other third-parties. Your use of our Mobile Application and Services grants you no right or license to reproduce or otherwise use any Pegasus Medical (1808) Ltd or third-party trademarks.', style: TextStyle(color: bluePurple)),
                        SizedBox(height: 10,),
                        Text('Disclaimer of warranty', style: TextStyle(fontWeight: FontWeight.bold, color: bluePurple, fontSize: 16),),
                        SizedBox(height: 5,),

                        Text('You agree that your use of our Mobile Application or Services is solely at your own risk. You agree that such Service is provided on an "as is" and "as available" basis. We expressly disclaim all warranties of any kind, whether express or implied, including but not limited to the implied warranties of merchantability, fitness for a particular purpose and non-infringement. We make no warranty that the Services will meet your requirements, or that the Service will be uninterrupted, timely, secure, or error-free; nor do we make any warranty as to the results that may be obtained from the use of the Service or as to the accuracy or reliability of any information obtained through the Service or that defects in the Service will be corrected. You understand and agree that any material and/or data downloaded or otherwise obtained through the use of Service is done at your own discretion and risk and that you will be solely responsible for any damage to your computer system or loss of data that results from the download of such material and/or data. We make no warranty regarding any goods or services purchased or obtained through the Service or any transactions entered into through the Service. No advice or information, whether oral or written, obtained by you from us or through the Service shall create any warranty not expressly made herein.', style: TextStyle(color: bluePurple)),
                        SizedBox(height: 10,),
                        Text('Limitation of liability', style: TextStyle(fontWeight: FontWeight.bold, color: bluePurple, fontSize: 16),),
                        SizedBox(height: 5,),

                        Text('To the fullest extent permitted by applicable law, in no event will Pegasus Medical (1808) Ltd, its affiliates, officers, directors, employees, agents, suppliers or licensors be liable to any person for (a): any indirect, incidental, special, punitive, cover or consequential damages (including, without limitation, damages for lost profits, revenue, sales, goodwill, use of content, impact on business, business interruption, loss of anticipated savings, loss of business opportunity) however caused, under any theory of liability, including, without limitation, contract, tort, warranty, breach of statutory duty, negligence or otherwise, even if Pegasus Medical (1808) Ltd has been advised as to the possibility of such damages or could have foreseen such damages. To the maximum extent permitted by applicable law, the aggregate liability of Pegasus Medical (1808) Ltd and its affiliates, officers, employees, agents, suppliers and licensors, relating to the services will be limited to an amount greater of one pound or any amounts actually paid in cash by you to Pegasus Medical (1808) Ltd for the prior one month period prior to the first event or occurrence giving rise to such liability. The limitations and exclusions also apply if this remedy does not fully compensate you for any losses or fails of its essential purpose.', style: TextStyle(color: bluePurple)),
                        SizedBox(height: 10,),
                        Text('Indemnification', style: TextStyle(fontWeight: FontWeight.bold, color: bluePurple, fontSize: 16),),
                        SizedBox(height: 5,),
                        Text('You agree to indemnify and hold Pegasus Medical (1808) Ltd and its affiliates, directors, officers, employees, and agents harmless from and against any liabilities, losses, damages or costs, including reasonable attorneys fees, incurred in connection with or arising from any third-party allegations, claims, actions, disputes, or demands asserted against any of them as a result of or relating to your Content, your use of the Mobile Application or Services or any willful misconduct on your part.', style: TextStyle(color: bluePurple)),
                        SizedBox(height: 10,),
                        Text('Dispute resolution', style: TextStyle(fontWeight: FontWeight.bold, color: bluePurple, fontSize: 16),),
                        SizedBox(height: 5,),
                        Text('The formation, interpretation, and performance of this Agreement and any disputes arising out of it shall be governed by the substantive and procedural laws of Northumberland, United Kingdom without regard to its rules on conflicts or choice of law and, to the extent applicable, the laws of United Kingdom. The exclusive jurisdiction and venue for actions related to the subject matter hereof shall be the state and federal courts located in Northumberland, United Kingdom, and you hereby submit to the personal jurisdiction of such courts. You hereby waive any right to a jury trial in any proceeding arising out of or related to this Agreement. The United Nations Convention on Contracts for the International Sale of Goods does not apply to this Agreement.', style: TextStyle(color: bluePurple)),
                        SizedBox(height: 10,),
                        Text('Changes and amendments', style: TextStyle(fontWeight: FontWeight.bold, color: bluePurple, fontSize: 16),),
                        SizedBox(height: 5,),
                        Text('We reserve the right to modify this Agreement or its policies relating to the Mobile Application or Services at any time, effective upon posting of an updated version of this Agreement in the Mobile Application. When we do, we will revise the updated date at the bottom of this page. Continued use of the Mobile Application after any such changes shall constitute your consent to such changes.', style: TextStyle(color: bluePurple)),
                        SizedBox(height: 10,),
                        Text('Acceptance of these terms', style: TextStyle(fontWeight: FontWeight.bold, color: bluePurple, fontSize: 16),),
                        SizedBox(height: 5,),
                        Text('You acknowledge that you have read this Agreement and agree to all its terms and conditions. By using the Mobile Application or its Services you agree to be bound by this Agreement. If you do not agree to abide by the terms of this Agreement, you are not authorized to use or access the Mobile Application and its Services.', style: TextStyle(color: bluePurple)),
                        SizedBox(height: 10,),
                        Text('Contacting us', style: TextStyle(fontWeight: FontWeight.bold, color: bluePurple, fontSize: 16),),
                        SizedBox(height: 5,),
                        Text('If you would like to contact us to understand more about this Agreement or wish to contact us concerning any matter relating to it, you may send an email to pm1808app@gmail.com', style: TextStyle(color: bluePurple)),
                        SizedBox(height: 10,),
                        Text('This document was last updated on May 14, 2021', style: TextStyle(color: bluePurple)),
                      ],
                    ),),
                  SizedBox(height: 10,),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                    GradientButton('Decline', () => _declineTerms()),
                    SizedBox(width: 20,),
                    GradientButton('Accept', () => _acceptTerms())
                    ,
                  ],),
                  SizedBox(height: 20,),
                ],
                ));
          },
        ),
    );
  }
}
