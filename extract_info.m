%% This function is to extract all the information out of the bag file

%The output to the function are 
% Data           ---> [(all data with name and values)]
% Signal_Info  ---> [(Names of signals with more than one output),(Name of
% signals with 0 messages)]

function [Data,Signal_Info] = extract_info(input)
bagfile = rosbag(input); %Reads rosbagfile
Available_Topics = bagfile.AvailableTopics.Properties.RowNames; %Lists down available topics

value=0;info=0;null = 0; %Counter variables
% Data = 0; Value_Signals=0;Info_Signals=0;Null_Signals=0; %Preallocaation for speed

for a = 1:length(Available_Topics) %Loops over all the available topics to read meassages
    Data(a).Topic = Available_Topics{a}; 
    Data(a).TopicBag = select(bagfile,"Topic",Available_Topics{a});
    Data(a).Message = readMessages(Data(a).TopicBag,"DataFormat","Struct");
    if length(Data(a).Message) > 1
        value = value + 1;
        Signal_Info.Value_Signal{value,1} = Data(a).Topic;
       Signal_Info.Value_Signal{value,2} = a;
    elseif length(Data(a).Message) == 1
        info = info + 1;
        Signal_Info.Info_Signal{info,1} = Data(a).Topic;
        Signal_Info.Info_Signal{info,2} = a;
    else
        null = null + 1;
        Signal_Info.Null_Signal{null,1} = Data(a).Topic;
        Signal_Info.Null_Signal{null,2} = a;
    end   
end
end

%----Copyright --- Chhayank Srivastava ----