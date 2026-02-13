# Lockfile generation

## Prerequisite

* You must install [https://github.com/konflux-ci/rpm-lockfile-prototype](rpm-lockfile-prototype)

## Input file

The input files for lockfile generation are:

* rpms.in.yaml

## Generating the lockfile

```
rpm-lockfile-prototype rpms.in.yaml
```

## Commit the Result

* The above command will produce the lockfile - **rpms.lock.yaml**
* Commit any changes.
