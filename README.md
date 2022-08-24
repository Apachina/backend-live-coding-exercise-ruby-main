## Usage

```sh
bundle
ruby questionnaire.rb
```
Current implementation separate on two sides:
UserQuestionnaireService and StoreService.
UserQuestionnaireService is responsible for the working with user questions:
1) processing answers
2) counting ratings

StoreService is responsible for the working with pstore:
1) saving in file
2) getting data from file
3) getting keys/values etc.
I tried to make this service without relying on this task. So that in the future it could be reused for various purposes.
