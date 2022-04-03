classDiagram

    %% region ActivityServiceApi return list of activities when future list returned
    class ActivityServiceApi{
        +Api api
        +getAll(Map~String, dynamic~ map) Future~List~ 
        +getById(int id) Future~Activity~
        +add(Activity activity) Future~Activity~
        +updatePost(Activity activity) Future~Activity~
        +updatePatch(Map~String, dynamic~ map) Future~Activity~
        +delete(String id) Future~Activity~
        +joinActivityUser(Activity activity, int userId, bool hasJoin) Future~Activity~
    }

    class FriendsServiceApi{
        +Api api

        +getAll(Map~String, dynamic~ map) Future~List~ 
        +getById(int userId) Future~List~
        +getWaitingById(int userId) Future~List~
        +getWaitingAndValidateById(int userId) Future~List~
        +add(Map~String, int~ map) Future~User~
        +validateFriendship(Map~String, int~ map) Future~bool~
        +delete(Map~String, int~ map) Future~bool~
    }
    
    class MessageServiceApi {
        +Api api
      
        +getAll(Map~String, dynamic~ map) Future~List~ 
        +getById(int id) Future~List~
        +getConversationById(int id) Future~List~
        +add(int id, List~Message~ message) Future~Message~
    }

    class SportServiceApi{
        +Api api
      
        +getAll(Map~String, dynamic~ map) Future~List~ 
        +getById(int id) Future~Sport~
    }
            
    class UserServiceApi{
      +Api api
      
      +getAll(Map~String, dynamic~ map) Future~List~ 
      +getById(int id) Future~User~
      +getJWTTokenByGoogleToken(String tokenGoogle) Future~String~
      +getJWTTokenByLogin(Map~String, String~ login) Future~String~
      +setPublicKey(String publicKey) Future~bool~
      +add(User user) Future~User~
      +updatePost(User user) Future~User~
      +updatePatch(Map~String, dynamic~ map) Future~User~
      +delete(String id) Future~User~
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
            +handleUrlParams(bool isFirstParam, Map~String, dynamic~ map, List~String~ ignored) String
            +parseActivities(String responseBody) List~Activity~
            +parseSports(String responseBody) List~Sport~
            +parseUsers(String responseBody) List~User~
            +parseMessages(String responseBody) List~Message~
            +parseConversation(String responseBody) List~Conversation~
        }
        class ApiErr{
            int codeStatus;
            String message;
          
            +errMsg() String
            ApiErr(Map)
        }
        
        class AsymetricKeyGenerator {
            LocalStorage storage
            String indexPrivate
            String indexPublic
            String id
            
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
            List~String~ stateImpacted
    
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
            List~Level~ levelList$
        }
    
        class Mock {
            User userGwen$
            User user2$
        }
        %% endregion
        
        %% region Models
        class Activity{
            int? id
            Location location;
    
            User host;
            Sport sport;
    
            DateTime dateEnd;
            DateTime dateStart;
            String description;
            int isCanceled;
            Level level;
            int attendeesNumber;
            List~String~? currentParticipants;
            int? nbCurrentParticipants;
            DateTime? createdAt;
            DateTime? updatedAt;
    
            bool? public;
            Gender? criterionGender;
            bool? limitByLevel;
    
            +Activity(Map~String, dynamic~)
            +fromJson(Map~String, dynamic~ json)
            +toMap() Map
            +toJson() json
        }
    
        class Level {
            int id;
            String name;
    
            +Level(Map~String, dynamic~)
            +fromJson(Map~String, dynamic~ json)
            +toMap() Map
            +toJson() json
        }
        
        class Conversation {
            int? id;
            String name;
            int userId;
            String pubKey;
            DateTime? createdAt;
    
            +Conversation(Map~String, dynamic~)
            +fromJson(Map~String, dynamic~ json)
            +toMap() Map
            +toJson() json
        }
        class Message {
            int id;
            String bodyMessage;
            int idReceiver;
            int idSender;
            DateTime? createdAt;
    
            +Message(Map~String, dynamic~)
            +fromJson(Map~String, dynamic~ json)
            +toMap() Map
            +toJson() json
        }
    
        class Location {
            int? id;
            String address;
            String city;
            String country;
            double lat;
            double lon;
    
            +Location(Map~String, dynamic~)
            +fromJson(Map~String, dynamic~ json)
            +toMap() Map
            +toJson() json
        }
    
        class Sport {
            int id;
            String name;
    
            +Sport(Map~String, dynamic~)
            +fromJson(Map~String, dynamic~ json)
            +toMap() Map
            +toJson() json
        }
    
        class Availability{
            bool monday;
            bool tuesday;
            bool wednesday;
            bool thursday;
            bool friday;
            bool saturday;
            bool sunday;
    
            +Availability(Map~String, dynamic~)
            +fromJson(Map~String, dynamic~ json)
            +toMap() Map
            +toJson() json
        } 
    
        class User {
            int? id;
            String username;
            String mail;
            String role;
            String? password;
    
            Gender? gender;
            DateTime? birthday;
            Availability? availability;
            Location? location;
            DateTime? createdAt;
            List~int~? friendsList;
    
            +User(Map~String, dynamic~)
            +fromJson(Map~String, dynamic~ json)
            +toMap() Map
            +toJson() json
        }
        %% endregion
        
        
        %% region Use case api
        
        class ActivityUseCase {
            ActivityServiceApi api
    
            +getAll(Map~String, dynamic~ map) Future~List~
            +getById(int id) Future~Activity~
            +add(Activity activity) Future~Activity~
            +update(Activity activity) Future~Activity~
            +updatePartially(Map~String, dynamic~ map) Future~Activity~
            +joinActivityUser(Activity activity, int userId, bool hasJoin) Future~Activity~
            +delete(id) Future~Activity~
        }
    
        class FriendsUseCase {
            FriendsServiceApi api
    
            -_mapBody(int idUserSender, int idUserReceiver) Map
            +getById(int userId) Future~List~
            +getWaitingById(int userId) Future~List~
            +getWaitingAndValidateById(int userId) Future~List~
            +add(int idUserSender, int idUserReceiver) Future~User~
            +validateFriendship(int idUserSender, int idUserReceiver) Future~bool~
            +delete(int idUserSender, int idUserReceiver) Future~bool~
        }
        
        class MessageUseCase {
            MessageServiceApi api
    
            +getAll(Map~String, dynamic~ map) Future~List~
            +getById(int id) Future~List~
            +getConversationById(int id) Future~List~
            +add(int id, List~Message~ message) Future~Message~
        }
    
        class SportUseCase {
            SportServiceApi api
    
            +getAll(Map~String, dynamic~ map) Future~List~
            +getById(int id) Future~Sport~
        }
    
        class UserUseCase {
            UserServiceApi api
    
            +getAll(Map~String, dynamic~ map) Future~List~
            +getById(int id) Future~User~
            +getJWTTokenByGoogleToken(String tokenGoogle) Future~String~
            +getJWTTokenByLogin(Map~String, String~ login) Future~String~
            +setPublicKey(String publicKey) Future~bool~
            +add(User user) Future~User~
            +update(User user) Future~User~
            +updatePartially(Map~String, dynamic~ map) Future~User~
            +delete(id) Future~User~
        }
        %% endregion
        
        
        %% region components
        
        class ColumnList {
            String title;
            Icon? icon;
            Widget child;
    
            +ColumnList(Map)
            +build(BuildContext context) Widget
        }
    
        class CustomDatePicker {
            DateTime? initialDate;
            Function onSelected;
    
            +CustomDatePicker(Map)
            +build(BuildContext context) Widget
            -_selectDate(BuildContext context)
        }
    
        class CustomInput {
            String title;
            String notValidError;
            TextEditingController controller;
            TextInputType type;
    
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
            List~Widget~ children;
    
            +CustomColumn(Map)
            _buildWidgetList() List~Widget~
            +build(BuildContext context) Widget
        }
        
        class CustomRow {
            List~Widget~ children;
    
            +CustomRow(Map)
            -_buildWidgetList() List~Widget~
            +build(BuildContext context) Widget
        }
    
        class CustomText {
            +CustomText(String text, Map)
        }
        
        
        %% region Date component
        class BasicDateField {
            DateFormat format
    
            +build(BuildContext context) Widget
        }
    
        class BasicTimeField{
            DateFormat format
    
            +build(BuildContext context) Widget
        }
    
        class BasicDateTimeField{
            TextEditingController dateController
            DateFormat format
            +build(BuildContext context) Widget
        }
    
        class DateTimePickerButton{
            DateTime? datetime;
            Function onPressed;
    
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
            Function? onPressed;
            bool display;
    
            DeleteButton(Map)
            +build(BuildContext context) Widget
        }
    
        %% region dropdown
        class DropdownGender{
            String criterGender;
            Function onChange;
    
            DropdownGender(Map)
            -createState() _DropdownGenderState
        }
    
        class _DropdownGenderState{
            initState()
            dispose()
            +build(BuildContext context) Widget
        }
    
        class DropdownLevel{
            Level level;
            Function onChange;
    
            +DropdownLevel(Map)
            -createState() _DropdownLevelState
        }
        class _DropdownLevelState{
            List~Level~ levelList
            Level level
            
            initState()
            dispose()
            +build(BuildContext context) Widget
        }
        class DropdownSports{
            Sport sport;
            Function onChange;
    
            +DropdownSports(Map)
            -createState() _DropdownSportsState
        }
        class _DropdownSportsState{
            List~Sport~ futureSports
            LocalStorage storage
            SportUseCase sportUseCase
            Sport sport
    
            -_getSports() void
            initState()
            dispose()
            +build(BuildContext context) Widget
        }
        %% endregion
        
        class ListViewSeparated {
            dynamic data;
            Function buildListItem;
            Axis axis;
    
            ListViewSeparated(Map)
            +build(BuildContext context) Widget
        }
    
        class FilterDialog{
            DateTime? selectedDate;
            Function onSelectDate;
    
            Sport sport;
            List~Sport~ sportList;
            Function onChangeSport;
    
            FilterDialog(Map)
            -createState() _FilterDialogState
        }
    
        class _FilterDialogState{
            DateTime? selectedDate
            Sport sport;
            List~Sport~ sportList
            
            initState()
            +build(BuildContext context) Widget
            -_updateSelectedDate(DateTime date) 
            -_updateSelectedSport(Sport newSport)
        }
    
    
    
         class RadioPrivacy {
            bool isRow;
            Function onChange;
            dynamic groupValue;
    
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
            Location? location;
    
            MapDialog(Map)
            -createState() _MapDialogState
        }
    
        class _MapDialogState{
            LatLng? pos
            Location? location;
            
            initState()
            +build(BuildContext context) Widget
            -_updatePos(LatLng newPos) 
            -_updateLocation(Location newLocation)
            -_getPosition()
        }
    
        class CustomMap{
            LatLng? pos;
            Function onMark;
    
            +CustomMap(Map)
            -createState() _CustomMapState
        }
        class _CustomMapState{
            CameraPosition _initialCameraPosition; // use autorisation to initial position
            Marker? _origin;
            double zoom
            GoogleMapController _mapController;
    
            initState()
            dispose()
            +build(BuildContext context) Widget
            -getFirstFilled(List~dynamic~ list, Map) dynamic
            -getFirstFilledAndComplete(List~dynamic~ list, Map) dynamic
            -_getMoreComplete(String search, String subject) String
            -_addMarker(LatLng pos)
            -_getAddress(LatLng pos) Placemark
        }
        
        
        
        class TopSearchBar {
            Widget customSearchBar;
            TextEditingController searchbarController;
            Widget? leading;
            String? placeholder;
    
            TopSearchBar(Map)
            -createState() _TopSearchBarState
            preferredSize() Size
        }
        class _TopSearchBarState{
            Widget customSearchBar
            Icon customIcon
    
            initState()
            build(BuildContext context) Widget
        }
    
        class SearchBar{
            String? placeholder;
            TextEditingController searchbarController;
    
            build(BuildContext context) Widget
            SearchBar(Map)
        }
    
    
        class TextIcon{
            String title;
            Icon? icon;
            
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
            ActivityUseCase activityUseCase
            SportUseCase sportUseCase
            LocalStorage storage
    
            Future~List~Activity>> futureActivities;
    
            User currentUser;
            String keywords
            Sport sport;
            List~Sport~ futureSports
            DateTime? selectedDate
    
            searchbarController
    
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
            -_filterActivities(List~Activity~ list) List~Activity~
            -_fieldContains(Activity activity) bool
            -_updateKeywords()
        }
    
        class ActivityDetailsScreen{
            Activity activity;
            const tag$;
    
            ActivityDetailsScreen(Map)
            createState() _ActivityDetailsScreenState
        }
        class _ActivityDetailsScreenState{
            ActivityUseCase activityUseCase
            User currentUser
            Activity activity;
            
            initState()
            +build(BuildContext context) Widget
        }
    
    
        class ActivityCreate{
            Activity? activity;
            const tag$;
    
            ActivityCreate(Map)
            createState() _ActivityCreateState
        }
    
    
        class _ActivityCreateState{
            ActivityUseCase activityUseCase
            LocalStorage storage
    
            Sport sport;
            User currentUser
    
            _formKey
            TextEditingController eventDescriptionInput
            TextEditingController nbManquantsInput
            TextEditingController nbTotalParticipantsInput
    
            String criterGender
            Level eventLevel
            String eventDescription
            int nbTotalParticipants
            Duration _duration
            bool public
    
            DateTime dateTimeEvent
            Location? location
            bool isUpdating
            
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
            FriendsUseCase friendsUseCase
            UserUseCase userUseCase
            _biggerFont
            Future~List~User>> futureUsers;
            List~User~ futureFriends;
            List~int~ friendsId;
            User currentUser
            searchbarController
            String keywords
    
            initState()
            dispose()
            build(BuildContext context) Widget
            -_updateKeywords() 
            -_filterFriends(List~User~ list) List~User~
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
            Completer~GoogleMapController~ _controller
            CameraPosition _initialCameraPosition
            Marker? _origin;
            Marker? _destination;
            double zoom
            GoogleMapController _mapController
    
            dispose()
            build(BuildContext context) Widget
            -_onMapCreated(GoogleMapController controller)
            -_originButton() Widget
            -_addMarker(LatLng pos)
        }
        
        
        class Authentication{
            signInWithGoogle(Map)$ Future~User?~
            customSnackBar(Map)$ SnackBar
            initializeFirebase(Map)$ Future~FirebaseApp~
            signOut(Map)$ 
            +build(BuildContext context) Widget
        }
    
    
        class FriendsList{
            FriendsList(Map)
            createState() _FriendsListState
        }
    
    
        class _FriendsListState{
            FriendsUseCase friendsUseCase
            _biggerFont
            Future~List~User>> futureUsers;
            User currentUser
            searchbarController
            String keywords
            
            initState()
            dispose()
            +build(BuildContext context) Widget
            -_updateKeywords()
            -_filterFriends(List~User~ list) List~User~
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
            
            Navigation(Map)
            createState() NavigationState
        }
    
    
        class NavigationState{
            int _selectedIndex
            int _drawerSelectedIndex
            bool _isLastTappedDrawer
            User user;
            LocalStorage storage
            List~Map~ drawerLinks
            List~Map~ bottomBarLinks
    
            initState()
            +build(BuildContext context) Widget
            -getBody() Widget
            -getDrawerLinks(BuildContext context) List~Widget~
            -getBottomBarLinks() List~BottomNavigationBarItem~
            -_onItemTapped(int index)
            -_onDrawerTap(int index, BuildContext context)
            -_buildDrawerLinks(String title, Function onTap)
            -_buildBottomBarButton(int index) BottomNavigationBarItem
        }
        
        
        
        class UserProfile {
            User user;
    
            UserProfile(Map)
            -createState() _UserProfileState
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
            User _user;
            bool _isSigningOut
    
            initState()
            +build(BuildContext context) Widget
            -_routeToSignInScreen() Route
        }