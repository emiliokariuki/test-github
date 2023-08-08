import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:the_brand/Utilities/editor_screen.dart';
import 'package:the_brand/Utilities/navigate_util.dart';
import 'package:the_brand/blocs/CustomerPlan/get_plan_cubit.dart';
import 'package:the_brand/blocs/HomeContent/home_content_bloc.dart';
import 'package:the_brand/data/Models/category_model.dart';
import 'package:the_brand/Utilities/non_category_header.dart';
import 'package:the_brand/Utilities/placeholders.dart';
import 'package:the_brand/data/Models/product_model.dart';
import 'package:the_brand/data/Repositories/design_repository.dart';
import 'package:the_brand/data/Repositories/home_page_details.dart';
import 'package:the_brand/data/Repositories/user_repository.dart';
import 'package:the_brand/view/Home/Home.dart';
import 'package:the_brand/view/Home/Tab/Category/categories_page.dart';
import '../../Utilities/Configurations/shared_preferences_manager.dart';
import '../../Utilities/webview_screen.dart';
import '../../blocs/Similar products/similarproducts_bloc.dart';
import '../../blocs/blocs.dart';
import "dart:math" as math;

class DesignPage extends StatefulWidget {
  DesignPage({
    Key? key,
    required this.product,
    required this.homesBloc,
  }) : super(key: key);

  final Product product;
  final HomeContentBloc homesBloc;

  @override
  _DesignPageState createState() => _DesignPageState();
}

class _DesignPageState extends State<DesignPage> {
  HomeContentBloc get homesBloc => widget.homesBloc;

  static const platform = const MethodChannel(_channel);

  late SimilarproductsBloc similarProducts;

  static const String _channel = 'test_activity';

  GetPlanCubit? getPlanCubit;
  String? uid;

  @override
  void initState() {
    super.initState();

    similarProducts = SimilarproductsBloc()
      ..add(GetSimilarProducts(alias: product.alias!));
  }

  @override
  didChangeDependencies() async {
    super.didChangeDependencies();
    uid = await UserRepository().getToken();

    print("uid is $uid");
  }

  Product get product => widget.product;
  Widget showLoading() {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 30),
        alignment: Alignment.center,
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage("assets/images/logo.jpeg")),
          borderRadius: BorderRadius.circular(100),
        ),
      ),
    );
  }

  Stack DesignImage(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            CachedNetworkImage(
              height: MediaQuery.of(context).size.height * 0.4,
              width: MediaQuery.of(context).size.width,
              placeholder: (context, url) {
                return Center(
                    child: Image.asset(
                  "assets/images/logo.jpeg",
                  height: 120,
                  width: 120,
                ));
              },
              errorWidget: ((context, url, error) {
                return Center(
                    child: Image.asset(
                  "assets/images/logo.jpeg",
                  height: 120,
                  width: 120,
                ));
              }),
              imageUrl:
                  "https://www.thebrand.ai/taswira.php?image=/v/uploads/gallery/${product.picture}",
              fit: BoxFit.fitHeight,
              imageBuilder: (context, imageProvider) {
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
            Image.asset("assets/images/bar.png"),
          ],
        ),
        Positioned.fill(
          bottom: 20,
          left: 10,
          child: Align(
            alignment: Alignment.bottomLeft,
            child: FutureBuilder<List<Category>>(
                future:
                    HomeDetails().fetchProductCategory(alias: product.alias!),
                builder: (context, snapshot) {
                  print("it is heer");
                  print(snapshot.data);
                  if (!snapshot.hasData) {
                    return SizedBox.shrink();
                  }
                  if (snapshot.connectionState == ConnectionState.done) {
                    print("The categories are : ${snapshot.data}");
                    return SizedBox(
                      height: 30,
                      width: MediaQuery.of(context).size.width,
                      child: snapshot.data!.isEmpty
                          ? Container()
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data!.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CategoriesPage(
                                                  category:
                                                      snapshot.data![index],
                                                  homesBloc: homesBloc,
                                                )));
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    margin: EdgeInsets.only(right: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Color(0xff0D0D0D).withOpacity(0.7),
                                    ),
                                    child: Center(
                                      child: Text(
                                        snapshot.data![index].name!,
                                        style: GoogleFonts.quicksand(
                                          fontSize: 15,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                    );
                  } else {
                    return Container();
                  }
                }),
          ),
        ),
      ],
    );
  }

  // Widget _renderActionBtn(BuildContext context) {
  //   return FloatingActionButton.extended(
  //     backgroundColor: Theme.of(context).primaryColor,
  //     icon: Icon(
  //       Icons.edit,
  //       color: Colors.white,
  //       size: 20,
  //     ),
  //     label: Text(
  //       "Edit Design",
  //       style: GoogleFonts.quicksand(
  //         fontSize: 16,
  //         fontWeight: FontWeight.bold,
  //         color: Colors.white,
  //       ),
  //     ),
  //     onPressed: () async {
  //       await context.bloc<NewDesignBloc>()
  //         ..add(AddNewDesignBtnTapped(product));

  //       Future.delayed(const Duration(milliseconds: 1500), () async {
  //         print("calling _getNew");
  //         await _getNewActivity();
  //       });
  //     },
  //   );
  // }

  _getNewActivity({required String themeId, required String uid}) {
    try {
      return platform.invokeMethod('startNewActivity',
          {'themeid': themeId, "userid": uid, "hashbrand": "false"});
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  Widget _renderLoadingFab(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.white,
      onPressed: () {},
      child: Container(
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            LiquidSpinner(
              height: MediaQuery.of(context).size.height * 0.8,
              pad: 3,
              time: 2,
              diameter: 80,
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Image.asset(
                  "assets/images/logoalt.png",
                  width: 20,
                  height: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NewDesignBloc>(
            create: (context) => NewDesignBloc(
                dRepo: DesignRepository(), uRepo: UserRepository())),
      ],
      child: Builder(builder: (context) {
        return Scaffold(
            backgroundColor: Colors.white,
            body: RefreshIndicator(
              onRefresh: () {
                similarProducts.add(GetSimilarProducts(alias: product.alias!));
                return Future.value();
              },
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    elevation: 0,

                    // title: Text(
                    //  product.title!,
                    // style: GoogleFonts.quicksand(
                    //  fontSize: 22,
                    // fontWeight: FontWeight.bold,
                    // color: Colors.black,
                    //  ),
                    //),
                    backgroundColor: Colors.white,
                    automaticallyImplyLeading: true,
                    expandedHeight: MediaQuery.of(context).size.height * 0.38,
                    pinned: true,
                    iconTheme: IconThemeData(color: Colors.black),
                    flexibleSpace: FlexibleSpaceBar(
                      background: DesignImage(context),
                    ),
                  ),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      minHeight: 35.0,
                      maxHeight: 40.0,
                      child: Container(
                          color: Colors.white,
                          margin: EdgeInsets.only(left: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                product.title!,
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                                style: GoogleFonts.quicksand(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          )),
                    ),
                    pinned: true,
                  ),
                  SliverList(
                      delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "By ${product.shopName}",
                                      style: GoogleFonts.quicksand(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black38,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    // product.about != null
                                    //     ? Html(
                                    //         data: product.about,
                                    //         shrinkWrap: true,
                                    //         style: {
                                    //           "p": Style(
                                    //             textAlign: TextAlign.start,
                                    //             fontSize: FontSize(20),
                                    //             fontWeight: FontWeight.w500,
                                    //             color: Color(0xff666666),
                                    //           ),
                                    //           "h1": Style(
                                    //             textAlign: TextAlign.start,
                                    //             fontSize: FontSize(20),
                                    //             fontWeight: FontWeight.w500,
                                    //             color: Color(0xff666666),
                                    //           ),
                                    //           "h2": Style(
                                    //             textAlign: TextAlign.start,
                                    //             fontSize: FontSize(20),
                                    //             fontWeight: FontWeight.w500,
                                    //             color: Color(0xff666666),
                                    //           ),
                                    //           "h3": Style(
                                    //             textAlign: TextAlign.start,
                                    //             fontSize: FontSize(20),
                                    //             fontWeight: FontWeight.w500,
                                    //             color: Color(0xff666666),
                                    //           ),
                                    //           "h4": Style(
                                    //             textAlign: TextAlign.start,
                                    //             fontSize: FontSize(20),
                                    //             fontWeight: FontWeight.w500,
                                    //             color: Color(0xff666666),
                                    //           ),
                                    //           "h5": Style(
                                    //             textAlign: TextAlign.start,
                                    //             fontSize: FontSize(20),
                                    //             fontWeight: FontWeight.w500,
                                    //             color: Color(0xff666666),
                                    //           ),
                                    //           "h6": Style(
                                    //             textAlign: TextAlign.start,
                                    //             fontSize: FontSize(20),
                                    //             fontWeight: FontWeight.w500,
                                    //             color: Color(0xff666666),
                                    //           ),
                                    //         },
                                    //       )
                                    //     : SizedBox.shrink(),
                                    Container(
                                      height: 27,
                                      width: 70,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: product.price == "0"
                                            ? Colors.blue
                                            : Colors.orange,
                                      ),
                                      child: Center(
                                        child: Text(
                                          product.price == "0"
                                              ? "Free"
                                              : "Premium",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    NonCategoryHeader(
                                      text: "Similar Templates",
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    BlocProvider(
                                      create: (context) => similarProducts,
                                      child: Builder(builder: (context) {
                                        return BlocBuilder<SimilarproductsBloc,
                                            SimilarproductsState>(
                                          bloc: similarProducts,
                                          builder: (context, state) {
                                            if (state
                                                is SimilarProductsLoading) {
                                              return Center(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  height: 55,
                                                  width: 55,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image: AssetImage(
                                                            "assets/images/logo.jpeg")),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100),
                                                  ),
                                                ),
                                              );
                                            } else if (state
                                                is SimilarProductsLoaded) {
                                              print(
                                                  state.similarProducts.length);
                                              return state
                                                      .similarProducts.isEmpty
                                                  ? Center(
                                                      child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        height: 55,
                                                        width: 55,
                                                        decoration:
                                                            BoxDecoration(
                                                          image: DecorationImage(
                                                              image: AssetImage(
                                                                  "assets/images/logo.jpeg")),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100),
                                                        ),
                                                      ),
                                                    )
                                                  : GridView.builder(
                                                      padding: EdgeInsets.zero,
                                                      shrinkWrap: true,
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      gridDelegate:
                                                          SliverGridDelegateWithFixedCrossAxisCount(
                                                              mainAxisSpacing:
                                                                  8,
                                                              crossAxisSpacing:
                                                                  8,
                                                              crossAxisCount:
                                                                  3),
                                                      itemCount: state
                                                          .similarProducts
                                                          .length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return Semantics(
                                                          button: true,
                                                          child: InkWell(
                                                            onTap: () {
                                                              navigate(context,
                                                                  destination:
                                                                      DesignPage(
                                                                    product: state
                                                                            .similarProducts[
                                                                        index],
                                                                    homesBloc:
                                                                        homesBloc,
                                                                  ));
                                                            },
                                                            child:
                                                                CachedNetworkImage(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.1,
                                                              placeholder:
                                                                  (context,
                                                                      url) {
                                                                return Container(
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      0.1,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                          color: Color.fromARGB(
                                                                              255,
                                                                              243,
                                                                              243,
                                                                              243),
                                                                          // border: Border.all(width: 0.4, color: Color(0xff666666)),
                                                                          borderRadius:
                                                                              BorderRadius.circular(10)),
                                                                );
                                                              },
                                                              errorWidget:
                                                                  ((context,
                                                                      url,
                                                                      error) {
                                                                return Image
                                                                    .asset(
                                                                  "assets/images/logo.jpeg",
                                                                  height: 60,
                                                                  width: 60,
                                                                );
                                                              }),
                                                              imageUrl:
                                                                  "https://www.thebrand.ai/taswira.php?image=/v/uploads/gallery/${state.similarProducts[index].picture}",
                                                              fit: BoxFit
                                                                  .fitHeight,
                                                              imageBuilder:
                                                                  (context,
                                                                      imageProvider) {
                                                                return Material(
                                                                  elevation: 0,
                                                                  clipBehavior:
                                                                      Clip.antiAlias,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  child:
                                                                      AnimatedContainer(
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                      border: Border.all(
                                                                          width:
                                                                              0.4,
                                                                          color:
                                                                              Color(0xff666666)),
                                                                      image:
                                                                          DecorationImage(
                                                                        image:
                                                                            imageProvider,
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                                    ),
                                                                    duration: Duration(
                                                                        milliseconds:
                                                                            500),
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          ),
                                                        );
                                                      });
                                            } else if (state
                                                is SimilarProductsError) {
                                              return Center(
                                                child: Text(
                                                    "Error loading the products"),
                                              );
                                            } else {
                                              return Center(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  height: 55,
                                                  width: 55,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image: AssetImage(
                                                            "assets/images/logo.jpeg")),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100),
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                        );
                                      }),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    NonCategoryHeader(
                                      text: "New designs ...",
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    BlocBuilder<HomeContentBloc,
                                        HomeContentState>(
                                      bloc: homesBloc,
                                      builder: (context, state) {
                                        if (state is HomeContentLoading) {
                                          return Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.5,
                                              child: showLoading());
                                        } else if (state is HomeContentLoaded) {
                                          return Center(
                                            child: GridView.builder(
                                                padding: EdgeInsets.zero,
                                                shrinkWrap: true,
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                  mainAxisSpacing: 8,
                                                  crossAxisSpacing: 8,
                                                  crossAxisCount: 3,
                                                ),
                                                itemCount:
                                                    state.newDesigns!.length,
                                                itemBuilder: (context, index) {
                                                  return Semantics(
                                                    button: true,
                                                    child: InkWell(
                                                      onTap: () {
                                                        navigate(context,
                                                            destination:
                                                                DesignPage(
                                                              product: state
                                                                      .newDesigns![
                                                                  index],
                                                              homesBloc:
                                                                  homesBloc,
                                                            ));
                                                      },
                                                      child: CachedNetworkImage(
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.1,
                                                        placeholder:
                                                            (context, url) {
                                                          return Container(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.1,
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: Color
                                                                        .fromARGB(
                                                                      255,
                                                                      243,
                                                                      243,
                                                                      243,
                                                                    ),
                                                                    // border: Border.all(width: 0.4, color: Color(0xff666666)),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10)),
                                                          );
                                                        },
                                                        errorWidget: ((context,
                                                            url, error) {
                                                          return Image.asset(
                                                            "assets/images/logo.jpeg",
                                                            height: 60,
                                                            width: 60,
                                                          );
                                                        }),
                                                        imageUrl:
                                                            "https://www.thebrand.ai/taswira.php?image=/v/uploads/gallery/${state.newDesigns![index].picture}",
                                                        fit: BoxFit.fitHeight,
                                                        imageBuilder: (context,
                                                            imageProvider) {
                                                          return Material(
                                                            elevation: 0,
                                                            clipBehavior:
                                                                Clip.antiAlias,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            child:
                                                                AnimatedContainer(
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                border: Border.all(
                                                                    width: 0.4,
                                                                    color: Color(
                                                                        0xff666666)),
                                                                image:
                                                                    DecorationImage(
                                                                  image:
                                                                      imageProvider,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                              duration: Duration(
                                                                  milliseconds:
                                                                      500),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                }),
                                          );
                                        } else {
                                          return Container();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                    childCount: 1,
                  ))
                ],
              ),
            ),
            floatingActionButton: BlocListener<NewDesignBloc, NewDesignState>(
              listener: (context, state) {
                if (state is NewDesignAdded) {
                  Navigator.of(context).pop(true);
                }
              },
              child: BlocBuilder<NewDesignBloc, NewDesignState>(
                builder: (context, state) {
                  if (state is AddingNewDesign) {
                    return _renderLoadingFab(context);
                  } else if (state is NewDesignAdded) {
                    // _getNewActivity(themeId: state.themeId!, uid: state.uid);

                    SchedulerBinding.instance.addPostFrameCallback((_) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditorScreen(
                            url: "https://www.thebrand.ai/appEdit/index.php" +
                                "?" +
                                "themeid=" +
                                state.themeId! +
                                "&userid=" +
                                state.uid,
                          ),
                        ),
                      );
                    });

                    return SizedBox.shrink();
                  } else {
                    return FloatingActionButton.extended(
                        backgroundColor: Theme.of(context).primaryColor,
                        icon: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: Text(
                          "Edit Design",
                          style: GoogleFonts.quicksand(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () async {
                          final isPro =
                              await SharedPreferencesManager().getIsPro();

                          if (isPro) {
                            print("called 1");
                            await context.read<NewDesignBloc>()
                              ..add(AddNewDesignBtnTapped(product));
                          } else if (!isPro && product.price == "0") {
                            print("called 2");
                            await context.read<NewDesignBloc>()
                              ..add(AddNewDesignBtnTapped(product));
                          } else if (!isPro && product.price != "0") {
                            print("called 3");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                content: Text(
                                  'You need to subscribe to pro to use this template',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => HomePage(
                                initialPage: 3,
                              ),
                            ));
                          } else {
                            print("called 4");

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                content: Text(
                                  'You need to subscribe to pro to use this template',
                                  style: TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => HomePage(
                                initialPage: 3,
                              ),
                            ));
                          }
                        });
                  }
                },
              ),
            ));
      }),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => math.max(maxHeight, minHeight);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
