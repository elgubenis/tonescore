var Airscore = require('../index.js');

var tweet = new Airscore();

// When setting a text, an internal array of words will automatically be parsed by airscore
tweet.set('text', 'Some good text example with some negative and positive words. This is a well defined example. But it also contains some not so nice words');

// You can also set the words directly yourself.
// tweet.set('words', ['good', 'bad']);

// Add the tones by which you want to rate your text

// Every tone has a label/type and an array of words, each word has its own weight, the weight is optional and defaults to: 1
tweet.addTone('positive', [
    { word: 'good', weight: 1 },
    { word: 'positive', weight: 1 },
    { word: 'well', weight: 1 },
    { word: 'nice', weight: 1.5 }
]);

tweet.addTone('negative', [
    { word: 'bad', weight: 1.5 },
    { word: 'not' },
    { word: 'negative' }
]);

// We can now call the method to get the individual scores.
var score = tweet.getScore(); // balance defaults to: 'fair'
console.log(score); // returns: { positive: '0.18', negative: '0.08' }

// The above example returns a 'fair' weight, counting every word of the text.
// We could instead only take into account the positive and negative words.
score = tweet.getScore({ balance: 'strict' });
console.log(score); // returns: { positive: '4.50', negative: '2.00' }

// Or in percent 'fair'
score = tweet.getScore({ percent: true });
console.log(score); // returns: { positive: '18.00%', negative: '8.00%' }

// In percent 'strict'
score = tweet.getScore({ balance: 'strict', percent: true });
console.log(score); // returns: { positive: '69.23%', negative: '30.77%' }

// You are in control of the decimals aswell. (percent or not..)
score = tweet.getScore({ balance: 'strict', percent: true, decimals: 6 });
console.log(score); // returns: { positive: '69.230769%', negative: '30.769231%' }