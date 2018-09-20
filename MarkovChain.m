
classdef MarkovChain
    properties
        transitionMatrix
        dataVector;
        dictLength;
        dictionary;
        inputData;
        inputLines={};
    end
    
    
    methods
        %function that generates a tweet
        function phrase = generate(obj)
            
            nextword = '';
            phrase = '';
            index=2;
            %while we havent reached the end of a tweet
            while ~strcmp('}',nextword)
                %find the total of a row
                total =  sum(obj.transitionMatrix(index,:));
                %pick a number within that range
                rng('shuffle');
                random = randi([1, total]);
                i=1;
                %subtract buy the value of each word until random becomes
                %negative, for a weighted random selection
                while random > 0
                    
                    random=random-obj.transitionMatrix(index,i);
                    
                    i=i+1;
                end
                %select new word and add it to phrase, then use last word
                %as new word.
                index =i-1;
                nextword=obj.dictionary(index);
                phrase = strcat(phrase, '_', nextword);
            end
            %finalize phrase by relpacing underscore with space, and return it. 
            phrase = extractBefore(phrase,'}');
            phrase = replace(phrase,'_',' ');
            
            phrase = char(phrase);
        end
        
        
        function obj = MarkovChain()
            %read from tweets line by line
            file = fopen('tweets.txt');
            line = fgetl(file);
            i=1;
            inputLines_= {};
            dataVector = '';
            %remove punctuation that is on either side of a word, not
            %punctiuation within a word
            %This was annoying to make.
            while(ischar(line))
                if size(line) ~= 0
                    j=1;
                    punctBlacklist = ['!','?','.',',','"',';',':','”','“'];
                    while any(line(1) ==punctBlacklist)
                        line(1)='';
                    end
                    while any(line(end) ==punctBlacklist)
                        line(end)='';
                    end
                    while j<= strlength(line)
                        if any(line(j) ==punctBlacklist) &&(line(j+1) == ' ' || line(j-1) == ' ')
                            line(j)='';
                            j=j-1;
                        else
                            j=j+1;
                        end
                    end
                    %add brackets to mark start and end, and add to list
                    %It may be slightly more efficient to preallocate this
                    %but I have no idea how to predict how many *words* are
                    %in a file without looping through it twice.
                    dataVector =[dataVector ' { ' line ' } '];
                    
                end
                %make all lowercase, and add to final list of real lines
                %It may be slightly more effiinent to preallocate this
                    %but I have no idea how to predict how many *lines* are
                    %in a file without looping through it twice.
                inputLines_{i} = lower(line);
                i=i+1;
                line = fgetl(file);
            end
            %stop reading
            fclose(file);
            %split up all the words into vectors of lowercase words
            dataVector = strsplit(dataVector);
            dataVector = lower(dataVector);
            %save our data to object
            obj.dataVector=dataVector;
            obj.inputLines=inputLines_;
            %add a new dictionary and transition matrix
            dictionary = strings(1,1);
            transitionMatrix=zeros(10000,10000);
            
            %tic
            %find if the current word is in the dicitonary
            currentStateIndex = find(strcmp(dataVector(1),dictionary));
            %if not add it
            if isempty(currentStateIndex)
                %It may be slightly more efficient to preallocate this
                %but I have no idea how to predict how many *unique words* are
                %in a file 
                dictionary(dictionary.length+1) = dataVector(1);
                currentStateIndex = dictionary.length;
                
            end
            
            %do for every word in the whole list
            for i  = 2:length(dataVector)
                %find if the next word is in the dicitonary
                nextStateIndex = find(strcmp(dataVector(i),dictionary));
                %if not add it
                if isempty(nextStateIndex)
                    
                    dictionary(dictionary.length+1) = dataVector(i);
                    nextStateIndex = dictionary.length;
                end
                %add one in the row of our current word, and the column of
                %our next word
                transitionMatrix(currentStateIndex,nextStateIndex)=transitionMatrix(currentStateIndex,nextStateIndex)+1;
                %move one forward, so our next word is now the current one.
                currentStateIndex=nextStateIndex;
            end
            %toc
            %shrink our transition matrix down to the size of our
            %dictionary
            transitionMatrix = transitionMatrix(1:dictionary.length,1:dictionary.length);
            %save our data to the object
            obj.transitionMatrix = transitionMatrix;
            obj.dictionary = dictionary;
            
        end
    end
end
