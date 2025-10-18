# whatmatter

whatmatter - a tool for identifying the most important topics.
In other wards, what matters to you the most.

The idea is to increment the score of particular topic each time you see it.
You do your everyday work and realize that something is important.
You call this script and promote the topic.
After some time you'll have a list with most important topics on the top.
whatsmatter is a tool for tracking and scoring important personal topics.

The original aim was to help choose what to learn next (e.g., a technology,
programming language, or framework).

## Platforms

* Linux
* MacOS

## Dependencies

* [fzf](https://github.com/junegunn/fzf) - a command-line fuzzy finder.
* sed - a stream editor for filtering and transforming text.

## Installation

```
curl -o "$HOME/.local/bin/whatmatter.sh" \
    -L https://raw.githubusercontent.com/apechinsky/whatmatter/refs/heads/master/whatmatter.sh && \
    chmod +x "$HOME/.local/bin/whatmatter.sh"
```

## Usage


* Add a term with score 1
```
whatmatter.sh score "term"
```

* Choose and score term
```
whatmatter.sh
```


