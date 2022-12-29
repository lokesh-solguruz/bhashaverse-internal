import 'dart:collection';
import 'dart:math';
import 'package:bhashaverse/utils/constants/api_constants.dart';
import 'package:get/get.dart';

import '../../enums/language_enum.dart';
import '../../models/search_model.dart';

class LanguageModelController extends GetxController {
  final Set<String> _allAvailableSourceLanguages = {};
  RxList<dynamic> get allAvailableSourceLanguages =>
      SplayTreeSet.from(_allAvailableSourceLanguages).toList().obs;

  final Set<String> _availableTargetLangsForSelectedSourceLang = {};
  Set<String> get availableTargetLangsForSelectedSourceLang =>
      SplayTreeSet.from(_availableTargetLangsForSelectedSourceLang);

  final Set<String> _allAvailableTargetLanguages = {};
  RxList<dynamic> get allAvailableTargetLanguages =>
      SplayTreeSet.from(_allAvailableTargetLanguages).toList().obs;

  late SearchModel _availableASRModels;
  SearchModel get availableASRModels => _availableASRModels;

  late SearchModel _availableTranslationModels;
  SearchModel get availableTranslationModels => _availableTranslationModels;

  late SearchModel _availableTTSModels;
  SearchModel get availableTTSModels => _availableTTSModels;

  void calcAvailableSourceAndTargetLanguages(List<dynamic> allModelList) {
    // TODO: Handel when perticular model not available
    _availableASRModels = allModelList.firstWhere((eachTaskResponse) {
      return eachTaskResponse['taskType'] == 'asr';
    })['modelInstance'];
    _availableTranslationModels = allModelList.firstWhere((eachTaskResponse) =>
        eachTaskResponse['taskType'] == 'translation')['modelInstance'];
    _availableTTSModels = allModelList.firstWhere((eachTaskResponse) =>
        eachTaskResponse['taskType'] == 'tts')['modelInstance'];

    //Retrieve ASR Models
    Set<String> availableASRModelLanguagesSet = {};
    for (Data eachASRModel in _availableASRModels.data) {
      availableASRModelLanguagesSet
          .add(eachASRModel.languages[0].sourceLanguage.toString());
    }

    //Retrieve TTS Models
    Set<String> availableTTSModelLanguagesSet = {};
    for (Data eachTTSModel in _availableTTSModels.data) {
      availableTTSModelLanguagesSet
          .add(eachTTSModel.languages[0].sourceLanguage.toString());
    }

    var availableTranslationModelsList = _availableTranslationModels.data;

    if (availableASRModelLanguagesSet.isEmpty ||
        availableTTSModelLanguagesSet.isEmpty ||
        availableTranslationModelsList.isEmpty) {
      throw Exception('Models not retrieved!');
    }

    Set<String> allASRAndTTSLangCombinationsSet = {};
    for (String eachASRAvailableLang in availableASRModelLanguagesSet) {
      for (String eachTTSAvailableLang in availableTTSModelLanguagesSet) {
        allASRAndTTSLangCombinationsSet
            .add('$eachASRAvailableLang-$eachTTSAvailableLang');
      }
    }
    Set<String> availableTransModelLangCombinationsSet = {};
    for (Data eachTranslationModel in availableTranslationModelsList) {
      availableTransModelLangCombinationsSet.add(
          '${eachTranslationModel.languages[0].sourceLanguage}-${eachTranslationModel.languages[0].targetLanguage}');
    }

    Set<String> canUseSourceAndTargetLangSet = allASRAndTTSLangCombinationsSet
        .intersection(availableTransModelLangCombinationsSet);

    for (String eachUseableLangPair in canUseSourceAndTargetLangSet) {
      _allAvailableSourceLanguages.add(APIConstants.getLanguageCodeOrName(
          value: eachUseableLangPair.split('-')[0],
          returnWhat: LanguageMap.devanagariName,
          lang_code_map: APIConstants.LANGUAGE_CODE_MAP));
      _allAvailableTargetLanguages.add(APIConstants.getLanguageCodeOrName(
          value: eachUseableLangPair.split('-')[1],
          returnWhat: LanguageMap.devanagariName,
          lang_code_map: APIConstants.LANGUAGE_CODE_MAP));
    }
  }

  String getAvailableASRModelsForLanguage(String languageCode) {
    List<String> availableASRModelsForSelectedLangInUIDefault = [];
    List<String> availableASRModelsForSelectedLangInUI = [];
    bool isAtLeastOneDefaultModelTypeFound = false;

    List<String> availableSubmittersList = [];
    for (var eachAvailableASRModelData in availableASRModels.data) {
      if (eachAvailableASRModelData.languages[0].sourceLanguage ==
          languageCode) {
        if (!availableSubmittersList
            .contains(eachAvailableASRModelData.name.toLowerCase())) {
          availableSubmittersList
              .add(eachAvailableASRModelData.name.toLowerCase());
        }
      }
    }

    availableSubmittersList = availableSubmittersList.toSet().toList();

    //Check OpenAI model availability
    String openAIModelName = '';
    for (var eachSubmitter in availableSubmittersList) {
      if (eachSubmitter.toLowerCase().contains(APIConstants
          .DEFAULT_MODEL_TYPES[APIConstants.TYPES_OF_MODELS_LIST[0]]!
          .split(',')[0]
          .toLowerCase())) {
        openAIModelName = eachSubmitter;
      }
    }

    //Check AI4Bharat Batch model availability
    String ai4BharatBatchModelName = '';
    for (var eachSubmitter in availableSubmittersList) {
      if (eachSubmitter.toLowerCase().contains(APIConstants
              .DEFAULT_MODEL_TYPES[APIConstants.TYPES_OF_MODELS_LIST[0]]!
              .split(',')[1]
              .toLowerCase()) &&
          eachSubmitter.toLowerCase().contains(APIConstants
              .DEFAULT_MODEL_TYPES[APIConstants.TYPES_OF_MODELS_LIST[0]]!
              .split(',')[2]
              .toLowerCase())) {
        ai4BharatBatchModelName = eachSubmitter;
      }
    }

    // //Check AI4Bharat Stream model availability
    // String ai4BharatStreamModelName = '';
    // for (var eachSubmitter in availableSubmittersList) {
    //   if (eachSubmitter.toLowerCase().contains(AppConstants.DEFAULT_MODEL_TYPES[AppConstants.TYPES_OF_MODELS_LIST[0]]!.split(',')[1].toLowerCase()) &&
    //       eachSubmitter.toLowerCase().contains(AppConstants.DEFAULT_MODEL_TYPES[AppConstants.TYPES_OF_MODELS_LIST[0]]!.split(',')[3].toLowerCase())) {
    //     ai4BharatStreamModelName = eachSubmitter;
    //   }
    // }

    //Check any AI4Bharat model availability
    String ai4BharatModelName = '';
    for (var eachSubmitter in availableSubmittersList) {
      if (eachSubmitter.toLowerCase().contains(APIConstants
              .DEFAULT_MODEL_TYPES[APIConstants.TYPES_OF_MODELS_LIST[0]]!
              .split(',')[1]
              .toLowerCase()) &&
          !eachSubmitter.toLowerCase().contains(APIConstants
              .DEFAULT_MODEL_TYPES[APIConstants.TYPES_OF_MODELS_LIST[0]]!
              .split(',')[2]
              .toLowerCase()) &&
          !eachSubmitter.toLowerCase().contains(APIConstants
              .DEFAULT_MODEL_TYPES[APIConstants.TYPES_OF_MODELS_LIST[0]]!
              .split(',')[3]
              .toLowerCase())) {
        ai4BharatModelName = eachSubmitter;
      }
    }

    if (openAIModelName.isNotEmpty) {
      for (var eachAvailableASRModelData in availableASRModels.data) {
        if (eachAvailableASRModelData.name.toLowerCase() ==
            openAIModelName.toLowerCase()) {
          availableASRModelsForSelectedLangInUIDefault
              .add(eachAvailableASRModelData.modelId);
          isAtLeastOneDefaultModelTypeFound = true;
        }
      }
    } else if (ai4BharatBatchModelName.isNotEmpty) {
      for (var eachAvailableASRModelData in availableASRModels.data) {
        if (eachAvailableASRModelData.name.toLowerCase() ==
            ai4BharatBatchModelName.toLowerCase()) {
          availableASRModelsForSelectedLangInUIDefault
              .add(eachAvailableASRModelData.modelId);
          isAtLeastOneDefaultModelTypeFound = true;
        }
      }
    }
    // else if (ai4BharatStreamModelName.isNotEmpty) {
    //   for (var eachAvailableASRModelData in _languageModelController.availableASRModels.data) {
    //     if (eachAvailableASRModelData.name.toLowerCase() == ai4BharatStreamModelName.toLowerCase()) {
    //       availableASRModelsForSelectedLangInUIDefault.add(eachAvailableASRModelData.modelId);
    //       isAtLeastOneDefaultModelTypeFound = true;
    //     }
    //   }
    // }
    else if (ai4BharatModelName.isNotEmpty) {
      for (var eachAvailableASRModelData in availableASRModels.data) {
        if (eachAvailableASRModelData.name.toLowerCase() ==
            ai4BharatModelName.toLowerCase()) {
          availableASRModelsForSelectedLangInUIDefault
              .add(eachAvailableASRModelData.modelId);
          isAtLeastOneDefaultModelTypeFound = true;
        }
      }
    } else {
      for (var eachAvailableASRModelData in availableASRModels.data) {
        if (eachAvailableASRModelData.languages[0].sourceLanguage ==
            languageCode) {
          availableASRModelsForSelectedLangInUI
              .add(eachAvailableASRModelData.modelId);
        }
      }
    }

    //Either select default model (vakyansh for now) or any random model from the available list.
    String asrModelIDToUse = isAtLeastOneDefaultModelTypeFound
        ? availableASRModelsForSelectedLangInUIDefault[Random()
            .nextInt(availableASRModelsForSelectedLangInUIDefault.length)]
        : availableASRModelsForSelectedLangInUI[
            Random().nextInt(availableASRModelsForSelectedLangInUI.length)];
    return asrModelIDToUse;
  }

  String getAvailableTranslationModel(
      String sourceLangCode, String targetLangCode) {
    List<String> availableTransModelsForSelectedLangInUIDefault = [];
    List<String> availableTransModelsForSelectedLangInUI = [];
    bool isAtLeastOneDefaultModelTypeFound = false;

    List<String> availableSubmittersList = [];
    for (var eachAvailableTransModelData in availableTranslationModels.data) {
      if (eachAvailableTransModelData.languages[0].sourceLanguage ==
              sourceLangCode &&
          eachAvailableTransModelData.languages[0].targetLanguage ==
              targetLangCode) {
        if (!availableSubmittersList
            .contains(eachAvailableTransModelData.name.toLowerCase())) {
          availableSubmittersList
              .add(eachAvailableTransModelData.name.toLowerCase());
        }
      }
    }
    availableSubmittersList = availableSubmittersList.toSet().toList();

    //Check AI4Bharat model availability
    String ai4BharatModelName = '';
    for (var eachSubmitter in availableSubmittersList) {
      if (eachSubmitter.toLowerCase().contains(APIConstants
          .DEFAULT_MODEL_TYPES[APIConstants.TYPES_OF_MODELS_LIST[1]]!
          .split(',')[0]
          .toLowerCase())) {
        ai4BharatModelName = eachSubmitter;
      }
    }

    if (ai4BharatModelName.isNotEmpty) {
      for (var eachAvailableTransModelData in availableTranslationModels.data) {
        if (eachAvailableTransModelData.name.toLowerCase() ==
            ai4BharatModelName.toLowerCase()) {
          availableTransModelsForSelectedLangInUIDefault
              .add(eachAvailableTransModelData.modelId);
          isAtLeastOneDefaultModelTypeFound = true;
        }
      }
    } else {
      for (var eachAvailableTransModelData in availableTranslationModels.data) {
        if (eachAvailableTransModelData.languages[0].sourceLanguage ==
                sourceLangCode &&
            eachAvailableTransModelData.languages[0].targetLanguage ==
                targetLangCode) {
          availableTransModelsForSelectedLangInUI
              .add(eachAvailableTransModelData.modelId);
        }
      }
    }

    //Either select default model (vakyansh for now) or any random model from the available list.
    String transModelIDToUse = isAtLeastOneDefaultModelTypeFound
        ? availableTransModelsForSelectedLangInUIDefault[Random()
            .nextInt(availableTransModelsForSelectedLangInUIDefault.length)]
        : availableTransModelsForSelectedLangInUI[
            Random().nextInt(availableTransModelsForSelectedLangInUI.length)];
    return transModelIDToUse;
  }
}
