import 'package:flutter/foundation.dart';

/// A class containing all string constants used across the app.
/// These strings help maintain consistency and make it easier to manage text content centrally.
@immutable
class Strings {
  // General app information
  static const appName = 'Unicorn Squad';
  static const welcomeToAppName = 'Welcome to ${Strings.appName}';
  static const loading = 'Loading...';

  static const or = 'or';

  // Messages related to posts
  static const youHaveNoPosts =
      'You have not made a post yet. Press either the video-upload or the photo-upload buttons at the top of the screen to upload your first post!';
  static const noPostsAvailable =
      "Nobody seems to have made any posts yet. Why don't you take the first step and upload your first post?!";

  // Search-related messages
  static const enterYourSearchTerm =
      'Enter your search term to get started. You can search in the description of all posts available in the system';

  // Third-party integration
  static const google = 'Google';
  static const googleSignupUrl = 'https://accounts.google.com/signup';

  // Login and account-related messages
  static const logIntoYourAccount = 'Log into your account.';
  static const dontHaveAnAccount = "Don't have an account?\n";
  static const signUpOn = 'Register ';
  static const orCreateAnAccountOn = ' or create an account on ';

  // Post interaction strings
  static const comments = 'Comments';
  static const writeYourCommentHere = 'Write your comment here...';
  static const checkOutThisPost = 'Check out this post!';
  static const postDetails = 'Post Details';
  static const post = 'post';
  static const createNewPost = 'Create New Post';
  static const pleaseWriteYourMessageHere = 'Please write your message here';

  // Comments-related message
  static const noCommentsYet =
      'Nobody has commented on this post yet. You can change that though, and be the first person who comments!';

  // Search input hint
  static const enterYourSearchTermHere = 'Enter your search term here';

  static const displayName = 'Display Name';

  static const profile = 'Profile';

  static const settings = 'Settings';

  static const chatboards = 'Chatboards';
  static const register = 'Register';

  static const logOut = 'Log out';
  static const logIn = 'Log in';
  static const wrongEmailOrPass = "Wrong email or password!";
  static const emailAlreadyExist = "Account with this email already exists";
  static const addChatboard = 'Add chatboard';

  static const avatarSetup = 'Avatar Setup';

  static const areYouSureThatYouWantToLogOutOfTheApp =
      'Are you sure that you want to log out of the app?';
  static const cancel = 'Cancel';

  static const List<String> roles = [
    "Unicorn",
    "Head-Unicorn",
    "Office-Unicorn",
    "Helper-Unicorn",
    "Unicorn Pro",
    "Alumni Unicorn"
  ];
  static const List<String> countries = ["Estonia", "Finland"];
  static const List<String> squads = [
    "HK Unicorn Squad",
    "Unicorn Office",
    "Viimsi Unicorn Squad",
    "Laulasmaa Unicornid"
  ];
  // Private constructor to prevent instantiation
  const Strings._();
}
