# whatsmatter

whatsmatter is a tool for tracking and scoring important personal topics.

This tool helps you maintain a list of important topics by incrementing a topic's score each time you encounter it.
Whenever you come across something important in your daily work, you can run the script to promote that topic.
Over time, this process ensures that your most important topics rise to the top of the list.

The original aim was to help choose what to learn next (e.g., a technology, programming language, or framework).

## Installation

```
curl -o "$HOME/.local/bin/whatsmatter.sh" \
    -L https://raw.githubusercontent.com/apechinsky/whatsmatter/refs/heads/master/whatsmatter.sh && \
    chmod +x "$HOME/.local/bin/whatsmatter.sh"
```

## Usage


* Add a term with score 1
```
whatsmatter.sh score "term"
```

* Choose and score term
```
whatsmatter.sh
```


