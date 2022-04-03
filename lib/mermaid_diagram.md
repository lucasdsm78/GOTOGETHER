classDiagram
@todo : 
- virer les 'final' et 'late'
- createState() : checker qu'on a createState() puis le type de return
- remplacer < et > par ~
- si un =, le supprimer et ce qui suit

    %% region ActivityServiceApi return list of activities when future list returned
    class ActivityServiceApi{
        +Api api
        +getAll(Map~String, dynamic~ map) Future~List~ 
        +getById(int id) Future<Activity>
        +add(Activity activity) Future<Activity>
        +updatePost(Activity activity) Future<Activity>
        +updatePatch(Map<String, dynamic> map) Future<Activity>
        +delete(String id) Future<Activity>
        +joinActivityUser(Activity activity, int userId, bool hasJoin) Future<Activity>
    }

    class FriendsServiceApi{
        +Api api

        +getAll(Map~String, dynamic~ map) Future~List~ 
        +getById(int userId) Future<List>
        +getWaitingById(int userId) Future<List>
        +getWaitingAndValidateById(int userId) Future<List>
        +add(Map<String, int> map) Future<User>
        +validateFriendship(Map<String, int> map) Future<bool>
        +delete(Map<String, int> map) Future<bool>
    }
    
    class MessageServiceApi {
        +Api api
      
        +getAll(Map~String, dynamic~ map) Future~List~ 
        +getById(int id) Future<List>
        +getConversationById(int id) Future<List>
        +add(int id, List<Message> message) Future<Message>
    }

    class SportServiceApi{
        +Api api
      
        +getAll(Map~String, dynamic~ map) Future~List~ 
        +getById(int id) Future<Sport>
    }
            
    class UserServiceApi{
      +Api api
      
      +getAll(Map~String, dynamic~ map) Future~List~ 
      +getById(int id) Future<User>
      +getJWTTokenByGoogleToken(String tokenGoogle) Future<String>
      +getJWTTokenByLogin(Map<String, String> login) Future<String>
      +setPublicKey(String publicKey) Future<bool>
      +add(User user) Future<User>
      +updatePost(User user) Future<User>
      +updatePatch(Map<String, dynamic> map) Future<User>
      +delete(String id) Future<User>
    }

    %% endregion 

    %% region helpers
        class Gender{
            <<enumeration>>
            +male
            +female
            +getIcon() Icon
            +toShortString() String
            +translate() String
        }
    
        class Privacy{
            <<enumeration>>
            +private
            +public
            +getIcon() Icon
            +toShortString() String
            +translate() String
            +isPublic() bool
        }
    
        class Api{
            http.Client client
            String host
            Map~String, dynamic~ mainHeader
            Api _instance$
            
            +Api()
            +setMainHeader(keyPara, val)
            +setToken(val)
            +handleUrlParams(bool isFirstParam, Map<String, dynamic> map, List<String> ignored) String
            +parseActivities(String responseBody) List<Activity>
            +parseSports(String responseBody) List<Sport>
            +parseUsers(String responseBody) List<User>
            +parseMessages(String responseBody) List<Message>
            +parseConversation(String responseBody) List<Conversation>
        }
        class ApiErr{
            int codeStatus;
            String message;
          
            +errMsg() String
            ApiErr(Map)
        }
        
        class AsymetricKeyGenerator {
            final LocalStorage storage = LocalStorage('go_together_app');
            final indexPrivate = "privateKey";
            final indexPublic = "pubKey";
            var id = "1";
            
            +setId(String newId)
            +getPubKeyFromStorage()
            +setPubKeyFromStorage(String pubKey)
            +getPrivateKeyFromStorage()
            +setPrivateKeyFromStorage(String privateKey)
            +generateKey(Map)
        }
        class EncryptionErr{
            int codeStatus;
            String message;
          
            errMsg() String
            EncryptionErr(Map)
        }
        
        class Notification{
            String name
            List<String> stateImpacted
    
            +Notification(Map~String, dynamic~)
        }
    
        class NotificationCenter{
            Notification userJoinActivity$
            Notification userCancelActivity$
            Notification createActivity$
            Notification updateActivity$
        }
    
        %% endregion
        
        %% region Mock
        class MockLevel{
            List<Level> levelList$
        }
    
        class Mock {
            User userGwen$
            User user2$
        }
        %% endregion
        
        %% region Models
        class Activity{
            int? id
            final Location location;
    
            final User host;
            final Sport sport;
    
            final DateTime dateEnd;
            final DateTime dateStart;
            final String description;
            final int isCanceled;
            final Level level;
            final int attendeesNumber;
            final List<String>? currentParticipants;
            final int? nbCurrentParticipants;
            final DateTime? createdAt;
            final DateTime? updatedAt;
    
            final bool? public;
            final Gender? criterionGender;
            final bool? limitByLevel;
    
            +Activity(Map~String, dynamic~)
            +fromJson(Map~String, dynamic~ json)
            +toMap() Map
            +toJson() json
        }
    
        class Level {
            final int id;
            final String name;
    
            +Level(Map~String, dynamic~)
            +fromJson(Map<String, dynamic> json)
            +toMap() Map
            +toJson() json
        }
        
        class Conversation {
            final int? id;
            final String name;
            final int userId;
            final String pubKey;
            final DateTime? createdAt;
    
            +Conversation(Map~String, dynamic~)
            +fromJson(Map<String, dynamic> json)
            +toMap() Map
            +toJson() json
        }
        class Message {
            final int id;
            final String bodyMessage;
            final int idReceiver;
            final int idSender;
            final DateTime? createdAt;
    
            +Message(Map~String, dynamic~)
            +fromJson(Map<String, dynamic> json)
            +toMap() Map
            +toJson() json
        }
    
        class Location {
            final int? id;
            final String address;
            final String city;
            final String country;
            final double lat;
            final double lon;
    
            +Location(Map~String, dynamic~)
            +fromJson(Map<String, dynamic> json)
            +toMap() Map
            +toJson() json
        }
    
        class Sport {
            final int id;
            final String name;
    
            +Sport(Map~String, dynamic~)
            +fromJson(Map<String, dynamic> json)
            +toMap() Map
            +toJson() json
        }
    
        class Availability{
            final bool monday;
            final bool tuesday;
            final bool wednesday;
            final bool thursday;
            final bool friday;
            final bool saturday;
            final bool sunday;
    
            +Availability(Map~String, dynamic~)
            +fromJson(Map<String, dynamic> json)
            +toMap() Map
            +toJson() json
        } 
    
        class User {
            final int? id;
            final String username;
            final String mail;
            final String role;
            final String? password;
    
            final Gender? gender;
            final DateTime? birthday;
            final Availability? availability;
            final Location? location;
            final DateTime? createdAt;
            late List<int>? friendsList;
    
            +User(Map~String, dynamic~)
            +fromJson(Map<String, dynamic> json)
            +toMap() Map
            +toJson() json
        }
        %% endregion
        
        
        %% region Use case api
        
        class ActivityUseCase {
            ActivityServiceApi api
    
            +getAll(Map<String, dynamic> map) Future<List>
            +getById(int id) Future<Activity>
            +add(Activity activity) Future<Activity>
            +update(Activity activity) Future<Activity>
            +updatePartially(Map<String, dynamic> map) Future<Activity>
            +joinActivityUser(Activity activity, int userId, bool hasJoin) Future<Activity>
            +delete(id) Future<Activity>
        }
    
        class FriendsUseCase {
            FriendsServiceApi api
    
            -_mapBody(int idUserSender, int idUserReceiver) Map
            +getById(int userId) Future<List>
            +getWaitingById(int userId) Future<List>
            +getWaitingAndValidateById(int userId) Future<List>
            +add(int idUserSender, int idUserReceiver) Future<User>
            +validateFriendship(int idUserSender, int idUserReceiver) Future<bool>
            +delete(int idUserSender, int idUserReceiver) Future<bool>
        }
        
        class MessageUseCase {
            MessageServiceApi api
    
            +getAll(Map<String, dynamic> map) Future<List>
            +getById(int id) Future<List>
            +getConversationById(int id) Future<List>
            +add(int id, List<Message> message) Future<Message>
        }
    
        class SportUseCase {
            SportServiceApi api
    
            +getAll(Map<String, dynamic> map) Future<List>
            +getById(int id) Future<Sport>
        }
    
        class UserUseCase {
            UserServiceApi api
    
            +getAll(Map<String, dynamic> map) Future<List>
            +getById(int id) Future<User>
            +getJWTTokenByGoogleToken(String tokenGoogle) Future<String>
            +getJWTTokenByLogin(Map<String, String> login) Future<String>
            +setPublicKey(String publicKey) Future<bool>
            +add(User user) Future<User>
            +update(User user) Future<User>
            +updatePartially(Map<String, dynamic> map) Future<User>
            +delete(id) Future<User>
        }
        %% endregion
        
        
        %% region components
        
        class ColumnList {
            final String title;
            final Icon? icon;
            final Widget child;
    
            +ColumnList(Map)
            +build(BuildContext context) Widget
        }
    
        class CustomDatePicker {
            final DateTime? initialDate;
            final Function onSelected;
    
            +CustomDatePicker(Map)
            +build(BuildContext context) Widget
            -_selectDate(BuildContext context)
        }
    
        class CustomInput {
            final String title;
            final String notValidError;
            final TextEditingController controller;
            final TextInputType type;
    
            +CustomInput(Map)
            -createState() _CustomInputState
        }
    
        class _CustomInputState{
            initState()
            dispose()
            +build(BuildContext context) Widget
            -_selectDate(BuildContext context)
        }
    
        class CustomColumn{
            final List<Widget> children;
    
            +CustomColumn(Map)
            _buildWidgetList() List<Widget>
            +build(BuildContext context) Widget
        }
        
        class CustomRow {
            final List<Widget> children;
    
            +CustomRow(Map)
            -_buildWidgetList() List<Widget>
            +build(BuildContext context) Widget
        }
    
        class CustomText {
            +CustomText(String text, Map)
        }
        
        
        %% region Date component
        class BasicDateField {
            final format = DateFormat("yyyy-MM-dd");
    
            +build(BuildContext context) Widget
        }
    
        class BasicTimeField{
            final format = DateFormat("HH:mm");
    
            +build(BuildContext context) Widget
        }
    
        class BasicDateTimeField{
            TextEditingController dateController
            final format = DateFormat("yyyy-MM-dd HH:mm");
            +build(BuildContext context) Widget
        }
    
        class DateTimePickerButton{
            final DateTime? datetime;
            final Function onPressed;
    
            +DateTimePickerButton(Map)
            -createState() _DateTimePickerButtonState
        }
        class _DateTimePickerButtonState{
            initState()
            dispose()
            +build(BuildContext context) Widget
        }
        %% endregion
        
        class DeleteButton {
            final Function? onPressed;
            final bool display;
    
            DeleteButton(Map)
            +build(BuildContext context) Widget
        }
    
        %% region dropdown
        class DropdownGender{
            final String criterGender;
            final Function onChange;
    
            -createState() _DropdownGenderState
            DropdownGender(Map)
        }
    
        class _DropdownGenderState{
            initState()
            dispose()
            +build(BuildContext context) Widget
        }
    
        class DropdownLevel{
            final Level level;
            final Function onChange;
    
            +DropdownLevel(Map)
            -createState() _DropdownLevelState
        }
        class _DropdownLevelState{
            List<Level> levelList = MockLevel.levelList;
            late Level level = widget.level ;
            
            initState()
            dispose()
            +build(BuildContext context) Widget
        }
        class DropdownSports{
            final Sport sport;
            final Function onChange;
    
            +DropdownSports(Map)
            -createState() _DropdownSportsState
        }
        class _DropdownSportsState{
            List<Sport> futureSports = [];
            final LocalStorage storage = LocalStorage('go_together_app');
            final SportUseCase sportUseCase = SportUseCase();
            late Sport sport = widget.sport ;
    
            -_getSports() void
            initState()
            dispose()
            +build(BuildContext context) Widget
        }
        %% endregion
        
        class ListViewSeparated {
            final dynamic data;
            final Function buildListItem;
            final Axis axis;
    
            ListViewSeparated(Map)
            +build(BuildContext context) Widget
        }
    
        class FilterDialog{
            final DateTime? selectedDate;
            final Function onSelectDate;
    
            final Sport sport;
            final List<Sport> sportList;
            final Function onChangeSport;
    
            -createState() _FilterDialogState
            FilterDialog(Map)
        }
    
        class _FilterDialogState{
            DateTime? selectedDate = DateTime.now();
            late Sport sport;
            List<Sport> sportList = [];
            
            initState()
            +build(BuildContext context) Widget
            -_updateSelectedDate(DateTime date) 
            -_updateSelectedSport(Sport newSport)
        }
    
    
    
         class RadioPrivacy {
            final bool isRow;
            final Function onChange;
            final dynamic groupValue;
    
            RadioPrivacy(Map)
            -createState() _RadioPrivacyState
        }
        class _RadioPrivacyState{
            initState()
            dispose()
            build(BuildContext context) Widget
            _buildRadio(String label, Object value, dynamic groupValue) Widget
        }
    
        class MapDialog{
            final Location? location;
    
            -createState() _MapDialogState
            MapDialog(Map)
        }
    
        class _MapDialogState{
            LatLng? pos ;
            Location? location;
            
            initState()
            +build(BuildContext context) Widget
            -_updatePos(LatLng newPos) 
            -_updateLocation(Location newLocation)
            -_getPosition()
        }
    
        class CustomMap{
            final LatLng? pos;
            final Function onMark;
    
            +CustomMap(Map)
            -createState() _CustomMapState
        }
        class _CustomMapState{
            late CameraPosition _initialCameraPosition; // use autorisation to initial position
            Marker? _origin;
            final double zoom = 11.0;
            late GoogleMapController _mapController;
    
            initState()
            dispose()
            +build(BuildContext context) Widget
            -getFirstFilled(List<dynamic> list, Map) dynamic
            -getFirstFilledAndComplete(List<dynamic> list, Map) dynamic
            -_getMoreComplete(String search, String subject) String
            -_addMarker(LatLng pos)
            -_getAddress(LatLng pos) Placemark
        }
        
        
        
        class TopSearchBar {
            final Widget customSearchBar;
            final TextEditingController searchbarController;
            final Widget? leading;
            final String? placeholder;
    
            TopSearchBar(Map)
            -createState() _TopSearchBarState
            preferredSize() Size
        }
        class _TopSearchBarState{
            Widget customSearchBar = const Text('');
            Icon customIcon = const Icon(Icons.search);
    
            initState()
            build(BuildContext context) Widget
        }
    
        class SearchBar{
            final String? placeholder;
            final TextEditingController searchbarController;
    
            build(BuildContext context) Widget
            SearchBar(Map)
        }
    
    
        class TextIcon{
            final String title;
            final Icon? icon;
            
            TextIcon(Map)
            +build(BuildContext context) Widget
        }
        %% endregion
        
        
        
        %% region screen activity
        class ActivityList {
            const tag$;
    
            ActivityList(Map)
            -createState() _ActivityListState
        }
        class _ActivityListState{
            final ActivityUseCase activityUseCase = ActivityUseCase();
            final SportUseCase sportUseCase = SportUseCase();
            final LocalStorage storage = LocalStorage('go_together_app');
    
            late Future<List<Activity>> futureActivities;
    
            late User currentUser;
            String keywords = "";
            late Sport sport;
            List<Sport> futureSports = [];
            DateTime? selectedDate;//DateTime.now();
    
            final searchbarController = TextEditingController();
    
            initState()
            dispose()
            build(BuildContext context) Widget
            -_seeMore(Activity activity)
            -slidableActionCurrentUserActivity(BuildContext context, Activity activity) Widget
            -_buildRow(Activity activity) Widget
            -dialogue()
            -criterionMap() Map
            -getSports() 
            -getActivities()
            -_updateSelectedDate(DateTime date)
            -_updateSelectedSport(Sport newSport)
            -_filterActivities(List<Activity> list) List<Activity>
            -_fieldContains(Activity activity) bool
            -_updateKeywords()
        }
    
        class ActivityDetailsScreen{
            final Activity activity;
            const tag$;
    
            createState() _ActivityDetailsScreenState
            ActivityDetailsScreen(Map)
        }
        class _ActivityDetailsScreenState{
            final ActivityUseCase activityUseCase = ActivityUseCase();
            late User currentUser = Mock.userGwen;
            late Activity activity;
            
            initState()
            +build(BuildContext context) Widget
        }
    
    
        class ActivityCreate{
            final Activity? activity;
            const tag$;
    
            createState() _ActivityCreateState
            ActivityCreate(Map)
        }
    
    
        class _ActivityCreateState{
            final ActivityUseCase activityUseCase = ActivityUseCase();
            final LocalStorage storage = LocalStorage('go_together_app');
    
            Sport sport;
            late User currentUser = Mock.userGwen;
    
            final _formKey = GlobalKey<FormState>();
            TextEditingController eventDescriptionInput = TextEditingController();
            TextEditingController nbManquantsInput = TextEditingController();
            TextEditingController nbTotalParticipantsInput = TextEditingController();
    
            String criterGender = 'Tous';
            late Level eventLevel = MockLevel.levelList[0];
            String eventDescription = "";
            int nbTotalParticipants = 0;
            Duration _duration = Duration(hours: 0, minutes: 0);
            bool public = false;
    
            DateTime dateTimeEvent = DateTime.now();
            Location? location ;
            bool isUpdating = false;
            
            initState()
            dispose()
            +build(BuildContext context) Widget
            -_setEventDate(DateTime date)
            -_setEventSport(Sport newSport)
            -_setEventLevel(Level newLevel)
            -_setEventGender(String newValue)
            -_setEventPrivacy(bool newValue)
            -mapDialogue()
            -_generateActivity() Activity
            -_addEvent()
        }
    
        %% endregion activity screen
        
        
        class AddFriendsList {
            const tag$;
    
            AddFriendsList(Map)
            -createState() _AddFriendsListState
        }
        class _AddFriendsListState{
            final FriendsUseCase friendsUseCase = FriendsUseCase();
            final UserUseCase userUseCase = UserUseCase();
            final _biggerFont = const TextStyle(fontSize: 18.0);
            late Future<List<User>> futureUsers;
            late List<User> futureFriends;
            late List<int> friendsId;
            late User currentUser = Mock.userGwen;
            final searchbarController = TextEditingController();
            String keywords = "";
    
            initState()
            dispose()
            build(BuildContext context) Widget
            -_updateKeywords() 
            -_filterFriends(List<User> list) List<User>
            -_fieldContains(User user) bool
            -_setFriends()
            -_seeMore(User user)
            -_addFriend(User user)
            -_buildRow(User user) Widget
        }
    
        class GotogetherApp{
            LocalStorage storage;
            SportUseCase sportUseCase;
    
            build(BuildContext context) Widget
            GotogetherApp(Map)
            -getSports()
        }
        class AppBarTitle{
            +build(BuildContext context) Widget
        }
    
    
        class CustomColors{
            Color firebaseNavy$
            Color firebaseOrange$
            Color firebaseAmber$
            Color firebaseYellow$
            Color firebaseGrey$
            Color googleBackground$
        }
        
        class MapScreen {
            const tag$;
    
            MapScreen(Map)
            -createState() _MapScreenState
        }
        class _MapScreenState{
            Completer<GoogleMapController> _controller
            CameraPosition _initialCameraPosition
            Marker? _origin;
            Marker? _destination;
            final double zoom = 11.0;
            GoogleMapController _mapController
    
            dispose()
            build(BuildContext context) Widget
            -_onMapCreated(GoogleMapController controller)
            -_originButton() Widget
            -_addMarker(LatLng pos)
        }
        
        
        class Authentication{
            signInWithGoogle(Map)$ Future<User?>
            customSnackBar(Map)$ SnackBar
            initializeFirebase(Map)$ Future<FirebaseApp>
            signOut(Map)$ 
            +build(BuildContext context) Widget
        }
    
    
        class FriendsList{
            createState() _FriendsListState
            FriendsList(Map)
        }
    
    
        class _FriendsListState{
            final FriendsUseCase friendsUseCase = FriendsUseCase();
            final _biggerFont = const TextStyle(fontSize: 18.0);
            late Future<List<User>> futureUsers;
            late User currentUser = Mock.userGwen;
            final searchbarController = TextEditingController();
            String keywords = "";
            
            initState()
            dispose()
            +build(BuildContext context) Widget
            -_updateKeywords()
            -_filterFriends(List<User> list) List<User>
            -_fieldContains(User user) bool
            -_seeMore(User user)
            -_buildRow(User user) Widget
        }
        
        
        class GoogleSignInButton {
            -createState() _GoogleSignInButtonState
        }
        class _GoogleSignInButtonState{
            bool _isSigningIn
    
            build(BuildContext context) Widget
        }
    
        class ConnexionGoogle{
            build(BuildContext context) Widget
        }
        
        class Navigation{
            tag$
            createState() NavigationState
            Navigation(Map)
        }
    
    
        class NavigationState{
            int _selectedIndex = 0;
            int _drawerSelectedIndex = 0;
            bool _isLastTappedDrawer = false;
            late User user;
            LocalStorage storage = LocalStorage('go_together_app');
            List<Map> drawerLinks
            List<Map> bottomBarLinks
    
            initState()
            +build(BuildContext context) Widget
            -getBody() Widget
            -getDrawerLinks(BuildContext context) List<Widget>
            -getBottomBarLinks() List<BottomNavigationBarItem>
            -_onItemTapped(int index)
            -_onDrawerTap(int index, BuildContext context)
            -_buildDrawerLinks(String title, Function onTap)
            -_buildBottomBarButton(int index) BottomNavigationBarItem
        }
        
        
        
        class UserProfile {
            final User user;
    
            -createState() _UserProfileState
            UserProfile(Map)
        }
        class _UserProfileState{
            User user
    
            initState()
            build(BuildContext context) Widget
        }
    
        class UserInfoScreen{
            User _user
    
            UserInfoScreen(Map)
            -createState() _UserInfoScreenState
        }
        class _UserInfoScreenState{
            late User _user;
            bool _isSigningOut = false;
    
            initState()
            +build(BuildContext context) Widget
            -_routeToSignInScreen() Route
        }