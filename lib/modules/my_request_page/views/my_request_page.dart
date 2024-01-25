import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_firebase_2/common/constants/app_constants.dart';
import 'package:flutter_bloc_firebase_2/modules/my_request_page/bloc/services_request/bloc/services_request_bloc.dart';
import 'package:flutter_bloc_firebase_2/modules/my_request_page/models/services_request.dart';
import 'package:flutter_bloc_firebase_2/modules/my_request_page/widgets/request_card.dart';
import 'package:flutter_bloc_firebase_2/modules/splash_page/splash_page.dart';

class MyRequestsPage extends StatefulWidget {
  const MyRequestsPage({super.key});

  @override
  State<MyRequestsPage> createState() => _MyRequestPageState();
}

class _MyRequestPageState extends State<MyRequestsPage> {
  List<ServicesRequest> servicesRequestList = <ServicesRequest>[];
  @override
  void initState() {
    // BlocProvider.of<ServicesRequestBloc>(context).add(FetchServicesRequest());
    context.read<ServicesRequestBloc>().add(FetchServicesRequest());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(238, 237, 237, 1),
      appBar: AppBar(
        title: const Text(
          'My Requests',
          style: TextStyle(
            fontFamily: 'poppins',
            fontWeight: FontWeight.normal,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color.fromRGBO(238, 237, 237, 0.6),
      ),
      body: Expanded(
          child: BlocConsumer<ServicesRequestBloc, ServicesRequestState>(
        listener: (context, state) {
          if (state.status == StateStatus.loading &&
              servicesRequestList.isNotEmpty) {}
          if (state.status == StateStatus.success &&
              servicesRequestList.isEmpty) {}
          if (state.status == StateStatus.failure &&
              servicesRequestList.isEmpty) {}
          return;
        },
        builder: (context, state) {
          if (state.status == StateStatus.initial ||
              (state.status == StateStatus.loading &&
                  servicesRequestList.isEmpty)) {
            return const LoadingPage();
          } else if (state.status == StateStatus.success) {
            servicesRequestList = state.servicesRequestList;
            servicesRequestList
                .sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
          } else if (state.status == StateStatus.failure &&
              servicesRequestList.isEmpty) {}
          return ListView.builder(
            itemCount: servicesRequestList.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: RequestCard(
                      servicesRequest: servicesRequestList[index],
                    ),
                  ),
                ],
              );
            },
          );
        },
      )),
    );
  }
}